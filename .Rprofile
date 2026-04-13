local_library <- file.path(getwd(), ".R", "library")

if (dir.exists(local_library)) {
  .libPaths(c(normalizePath(local_library), .libPaths()))
}

options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  tinytable_print_engine = "latex"
)
