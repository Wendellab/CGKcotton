"""Create a fresh chain control file while retaining IQ-TREE file compatibility."""
import argparse
import re
from pathlib import Path


def make_control(source, destination, seed, usedata, burnin, sampfreq, nsample):
    values = {}
    for line in source.read_text().splitlines():
        line = line.split('*', 1)[0].strip()
        if '=' in line:
            key, value = line.split('=', 1)
            values[key.strip()] = value.strip()
    required = ['seqfile', 'treefile', 'hessianfile', 'ndata', 'clock']
    if any(k not in values for k in required):
        raise ValueError('Expected an IQ-TREE-compatible MCMCtree control file')
    if values['ndata'] != '1' or values['clock'] != '2':
        raise ValueError('This workflow expects one partition and independent rates')
    for key in ['seqfile', 'treefile', 'hessianfile']:
        # Each chain gets copies of the matching small IQ-TREE inputs.
        original = Path(values[key])
        if not original.is_absolute():
            original = source.parent / original
        if not original.is_file():
            raise FileNotFoundError(original)
        values[key] = original.name
        target = destination.parent / original.name
        if target.exists():
            raise FileExistsError(target)
        target.write_bytes(original.read_bytes())
    topology = (destination.parent / values['treefile']).read_text()
    if not re.search(r"\)\s*'B\([0-9.eE+-]+,[0-9.eE+-]+\)'\s*;", topology):
        raise ValueError('Root B(min,max) calibration missing from generated PAML tree')
    values.update(seed=str(seed), usedata=str(usedata), checkpoint='1',
                  mcmcfile='mcmc.log', outfile='mcmctree.out', ckpfile='mcmctree.ckp',
                  burnin=str(burnin), sampfreq=str(sampfreq), nsample=str(nsample), print='1')
    # This IQ2MC build reads the likelihood filename from the usedata line.
    if usedata == 2:
        values['usedata'] = '2 ' + values['hessianfile']
    destination.write_text(''.join(f'{k} = {v}\n' for k, v in values.items()))


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('source', type=Path)
    p.add_argument('destination', type=Path)
    p.add_argument('--seed', type=int, required=True)
    p.add_argument('--usedata', type=int, choices=[0, 2], default=2)
    p.add_argument('--burnin', type=int, default=20000)
    p.add_argument('--sampfreq', type=int, default=100)
    p.add_argument('--nsample', type=int, default=20000)
    a = p.parse_args()
    if min(a.seed, a.sampfreq, a.nsample) <= 0 or a.burnin < 0:
        p.error('Invalid seed or chain lengths')
    make_control(a.source, a.destination, a.seed, a.usedata, a.burnin, a.sampfreq, a.nsample)
