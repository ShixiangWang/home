################
## 用rmd写博客 ##
################
# 作者：王诗翔
new_post <- function(post_name=NULL, dir=file.path(getwd(), "content/cn/post/"),
                     type=c('post'),
                     template_path = getwd(), add_prefix=TRUE, edit_file=TRUE,
                     force=FALSE){
  if(is.null(post_name)){
    stop("A post name must be given!")
  }

  type <- match.arg(type)
  if (type == "post"){
    template_name <- "template_post_cn.Rmd"
  } else {
    stop("Not supported!")
  }

  input_file      <- file.path(template_path, template_name)
  if (add_prefix) {
    current_time <- Sys.Date()
    out_file     <- paste0(dir, current_time, "-", post_name, ".Rmd")
  } else {
    out_file     <- paste0(dir, post_name, ".Rmd")
  }

  if (file.exists(out_file)) {
    if (!force) stop("File exists, use force=TRUE if you make sure rewrite it.")
  }
  message("Copying contents of ", input_file, " to ", out_file)
  fl_content     <- readLines(input_file)
  # Modify contents in template
  fl_content <- ifelse(grepl("date:", fl_content), paste0("date:", " \"", Sys.Date(), "\""), fl_content)
  writeLines(fl_content, out_file)
  if (edit_file) {
    file.edit(out_file)
  }
  message("New Rmarkdown post creat successfully!")
}
