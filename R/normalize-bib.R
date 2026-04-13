normalize_references <- function(bib_path = "manuscript/references.bib") {
  if (!file.exists(bib_path)) {
    stop("BibTeX file not found: ", bib_path, call. = FALSE)
  }

  lines <- readLines(bib_path, warn = FALSE, encoding = "UTF-8")

  skip_fields <- c("url", "doi", "file")
  current_field <- NULL

  normalize_text <- function(x) {
    # Invisible / whitespace variants -> regular space or empty
    x <- gsub("\u00A0", " ", x, fixed = TRUE)  # no-break space
    x <- gsub("\u202F", " ", x, fixed = TRUE)  # narrow no-break space
    x <- gsub("\u2009", " ", x, fixed = TRUE)  # thin space
    x <- gsub("\u200A", " ", x, fixed = TRUE)  # hair space
    x <- gsub("\u200B", "",  x, fixed = TRUE)  # zero-width space
    x <- gsub("\u200C", "",  x, fixed = TRUE)  # zero-width non-joiner
    x <- gsub("\u200D", "",  x, fixed = TRUE)  # zero-width joiner
    x <- gsub("\uFEFF", "",  x, fixed = TRUE)  # BOM / zero-width no-break space

    # Smart quotes and dashes
    x <- gsub("\u2018", "`", x, fixed = TRUE)
    x <- gsub("\u2019", "'", x, fixed = TRUE)
    x <- gsub("\u201C", "``", x, fixed = TRUE)
    x <- gsub("\u201D", "''", x, fixed = TRUE)
    x <- gsub("\u2013", "--", x, fixed = TRUE)
    x <- gsub("\u2014", "---", x, fixed = TRUE)
    x <- gsub("\u2212", "--", x, fixed = TRUE)

    # Greek letters commonly found in abstracts
    x <- gsub("\u03B1", "$\\\\alpha$",   x, fixed = TRUE)
    x <- gsub("\u03B2", "$\\\\beta$",    x, fixed = TRUE)
    x <- gsub("\u03B3", "$\\\\gamma$",   x, fixed = TRUE)
    x <- gsub("\u03B4", "$\\\\delta$",   x, fixed = TRUE)
    x <- gsub("\u03B5", "$\\\\epsilon$", x, fixed = TRUE)
    x <- gsub("\u03BB", "$\\\\lambda$",  x, fixed = TRUE)
    x <- gsub("\u03BC", "$\\\\mu$",      x, fixed = TRUE)
    x <- gsub("\u03C0", "$\\\\pi$",      x, fixed = TRUE)
    x <- gsub("\u03C1", "$\\\\rho$",     x, fixed = TRUE)
    x <- gsub("\u03C3", "$\\\\sigma$",   x, fixed = TRUE)
    x <- gsub("\u03C6", "$\\\\phi$",     x, fixed = TRUE)

    # Math symbols commonly found in abstracts
    x <- gsub("\u2208", "$\\\\in$",      x, fixed = TRUE)
    x <- gsub("\u2192", "$\\\\to$",      x, fixed = TRUE)
    x <- gsub("\u221E", "$\\\\infty$",   x, fixed = TRUE)
    x <- gsub("\u2264", "$\\\\leq$",     x, fixed = TRUE)
    x <- gsub("\u2265", "$\\\\geq$",     x, fixed = TRUE)
    x <- gsub("\u2260", "$\\\\neq$",     x, fixed = TRUE)
    x <- gsub("\u00D7", "$\\\\times$",   x, fixed = TRUE)

    # LaTeX special characters
    x <- gsub("(?<!\\\\)&", "\\\\&", x, perl = TRUE)
    x <- gsub("(?<!\\\\)%", "\\\\%", x, perl = TRUE)
    x <- gsub("(?<!\\\\)#", "\\\\#", x, perl = TRUE)
    x <- gsub("(?<!\\\\)_", "\\\\_", x, perl = TRUE)
    x <- gsub("(?<!\\\\)\\$", "\\\\$", x, perl = TRUE)
    x
  }

  normalized <- vapply(
    lines,
    FUN.VALUE = character(1),
    FUN = function(line) {
      if (grepl("^\\s*@", line, perl = TRUE)) {
        current_field <<- NULL
        return(line)
      }

      if (grepl("^\\s*}\\s*,?\\s*$", line, perl = TRUE)) {
        current_field <<- NULL
        return(line)
      }

      field_match <- regexec("^\\s*([A-Za-z]+)\\s*=", line, perl = TRUE)
      field_capture <- regmatches(line, field_match)[[1]]

      if (length(field_capture) > 1) {
        current_field <<- tolower(field_capture[[2]])
      }

      line_out <- line

      if (!is.null(current_field) && !current_field %in% skip_fields) {
        line_out <- normalize_text(line_out)
      }

      if (!is.null(current_field) && grepl("[}\"]\\s*,?\\s*$", line, perl = TRUE)) {
        current_field <<- NULL
      }

      line_out
    }
  )

  writeLines(normalized, bib_path, useBytes = TRUE)
  cat("Normalized bibliography fields in ", bib_path, "\n", sep = "")
}