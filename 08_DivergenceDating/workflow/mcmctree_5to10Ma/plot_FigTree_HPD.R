# Plot an MCMCtree FigTree.tre with node age 95% HPD bars; base R only.
# Run in the tree folder: Rscript plot_FigTree_HPD.R
# Optional: Rscript plot_FigTree_HPD.R FigTree.tre 100 "Age (Ma)"
# Use a scale factor only when the calibration time unit is known.
args <- commandArgs(trailingOnly = TRUE)
input <- if (length(args)) args[1] else "FigTree.tre"
scale_factor <- if (length(args) >= 2) as.numeric(args[2]) else 1
axis_label <- if (length(args) >= 3) args[3] else "Age before present (original tree time units)"
stopifnot(is.finite(scale_factor), scale_factor > 0)
input <- normalizePath(input, mustWork = TRUE)
prefix <- file.path(dirname(input), "FigTree_HPD")
raw <- paste(readLines(input, warn = FALSE), collapse = " ")
match_tree <- regexpr("(?i)\\b(?:UTREE|TREE)\\s+[^=]+?=\\s*", raw, perl = TRUE)
if (match_tree[1] < 0) stop("No TREE/UTREE statement found.")
s <- substring(raw, match_tree[1] + attr(match_tree, "match.length"))
s <- sub(";.*$", ";", s)
# Recursive parser: retain annotations on their own nodes, including the root.
pos <- 1L
nodes <- list()
peek <- function() substr(s, pos, pos)
skip <- function() {
  while (pos <= nchar(s) && grepl("\\s", peek())) pos <<- pos + 1L
}
parse_node <- function() {
  skip()
  children <- integer()
  if (peek() == "(") {
    pos <<- pos + 1L
    repeat {
      children <- c(children, parse_node())
      skip()
      if (peek() == ")") { pos <<- pos + 1L; break }
      if (peek() != ",") stop("Expected comma at position ", pos)
      pos <<- pos + 1L
    }
  }
  skip()
  label <- ""
  while (pos <= nchar(s) && !grepl("[\\s\\[\\]:,();]", peek(), perl = TRUE)) {
    label <- paste0(label, peek()); pos <<- pos + 1L
  }
  branch <- 0
  hpd <- c(NA_real_, NA_real_)
  repeat {
    skip()
    if (peek() == "[") {
      start <- pos
      while (pos <= nchar(s) && peek() != "]") pos <<- pos + 1L
      if (pos > nchar(s)) stop("Unclosed annotation.")
      annotation <- substr(s, start, pos)
      pos <<- pos + 1L
      hit <- regexec("(?:95%HPD|height_95%_HPD)\\s*=\\s*\\{([^}]+)\\}", annotation)
      values <- regmatches(annotation, hit)[[1]]
      if (length(values)) {
        hpd <- as.numeric(strsplit(values[2], ",", fixed = TRUE)[[1]])
        if (length(hpd) != 2L || any(!is.finite(hpd)) || hpd[1] > hpd[2]) stop("Invalid HPD.")
      }
    } else if (peek() == ":") {
      pos <<- pos + 1L; skip(); start <- pos
      while (pos <= nchar(s) && grepl("[0-9.eE+\\-]", peek())) pos <<- pos + 1L
      branch <- as.numeric(substr(s, start, pos - 1L))
      if (!is.finite(branch) || branch < 0) stop("Invalid branch length.")
    } else break
  }
  id <- length(nodes) + 1L
  nodes[[id]] <<- list(children = children, label = label, branch = branch, hpd = hpd)
  id
}
root <- parse_node()
skip()
if (peek() != ";") stop("Unexpected text after tree.")
n <- length(nodes)
tips <- which(vapply(nodes, function(z) !length(z$children), logical(1)))
internal <- setdiff(seq_len(n), tips)
depth <- y <- numeric(n)
y[tips] <- rev(seq_along(tips))
walk <- function(id) {
  for (child in nodes[[id]]$children) {
    depth[child] <<- depth[id] + nodes[[child]]$branch
    walk(child)
  }
  if (length(nodes[[id]]$children)) y[id] <<- mean(y[nodes[[id]]$children])
}
walk(root)
spread <- diff(range(depth[tips]))
# Allow rounding of the six-decimal branch lengths in MCMCtree output.
if (spread > 1e-5 * max(1, max(depth[tips]))) stop("Tree is not ultrametric; age calculation requires contemporaneous tips.")
age <- (mean(depth[tips]) - depth) * scale_factor
age[tips] <- 0
lo <- vapply(nodes, function(z) z$hpd[1], numeric(1)) * scale_factor
hi <- vapply(nodes, function(z) z$hpd[2], numeric(1)) * scale_factor
bars <- internal[is.finite(lo[internal]) & is.finite(hi[internal])]
if (!length(bars)) stop("No node HPD annotations found.")
descendants <- function(id) {
  if (!length(nodes[[id]]$children)) return(nodes[[id]]$label)
  unlist(lapply(nodes[[id]]$children, descendants), use.names = FALSE)
}
tab <- data.frame(plot_node_id = internal, age = age[internal],
                  HPD_lower = lo[internal], HPD_upper = hi[internal],
                  descendant_tips = vapply(internal, function(i) paste(descendants(i), collapse = ";"), character(1)))
write.csv(tab, paste0(prefix, "_nodes.csv"), row.names = FALSE)
draw <- function() {
  par(mar = c(4.5, 2, 4, 2), family = "sans", xaxs = "i", yaxs = "i")
  xmax <- max(age, hi, na.rm = TRUE) * 1.04
  plot(NA, xlim = c(xmax, -xmax * 0.30), ylim = c(0, length(tips) + 1),
       xlab = axis_label, ylab = "", axes = FALSE,
       main = "Dated phylogeny with node age uncertainty")
  ticks <- pretty(c(0, xmax), n = 7)
  ticks <- ticks[ticks >= 0 & ticks <= xmax]
  abline(v = ticks, col = "#EDF0F3", lwd = 0.8)
  for (i in bars) rect(lo[i], y[i] - 0.15, hi[i], y[i] + 0.15,
                       col = adjustcolor("#3182BD", alpha.f = 0.5), border = NA)
  for (i in internal) {
    ch <- nodes[[i]]$children
    segments(age[i], min(y[ch]), age[i], max(y[ch]), col = "#283747", lwd = 1)
    segments(age[i], y[ch], age[ch], y[ch], col = "#283747", lwd = 1)
  }
  points(age[internal], y[internal], pch = 16, cex = 0.35, col = "#183B56")
  text(rep(-xmax * 0.012, length(tips)), y[tips],
       vapply(nodes[tips], function(z) z$label, character(1)), adj = 0, cex = 0.72)
  axis(1, at = ticks, labels = format(ticks, trim = TRUE), col = "#657786", cex.axis = 0.85)
  mtext(sprintf("%d tips | %d internal nodes | blue bars: 95%% HPD", length(tips), length(internal)),
        side = 3, line = 0.5, cex = 0.85, col = "#52616B")
}
height <- max(7, length(tips) * 0.22 + 1.5)
pdf(paste0(prefix, ".pdf"), width = 12, height = height, useDingbats = FALSE)
draw(); invisible(dev.off())
png(paste0(prefix, ".png"), width = 12, height = height, units = "in", res = 180)
draw(); invisible(dev.off())
if (interactive()) draw()
cat(sprintf("Parsed %d tips, %d internal nodes; plotted %d HPD bars.\n", length(tips), length(internal), length(bars)))
cat(sprintf("Root age: %.7g; 95%% HPD: [%.7g, %.7g]\n", age[root], lo[root], hi[root]))
cat(sprintf("Tip depth spread (rounding): %.7g\n", spread))
cat("Saved:", paste0(prefix, c(".pdf", ".png", "_nodes.csv")), sep = "\n")
