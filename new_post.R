################
## 用rmd写博客 ##
################
# 作者：王诗翔
# 更新日期：2018-03-22
# 支持技术博文和小诗
new_post <- function(post_name=NULL, type = c('post', 'poem'),
                     template_path = getwd()){
  if(is.null(post_name)){
    stop("A post name must be given!")
  }

  type <- match.arg(type)
  if (type == "post"){
    template_name <- "post_template.Rmd"
    post_path <- paste0(getwd(),"/content/post/") # modify path for you categories
  }
  if (type == "poem"){
    template_name <- "poem_template.Rmd"
    post_path <- paste0(getwd(),"/content/post/")
  }


  input_file   <- paste(template_path,template_name, sep="/")
  current_time <- Sys.Date()
  out_file     <- paste0(post_path, current_time, "-",post_name,".Rmd")
  fl_content   <- readLines(input_file)
  writeLines(fl_content, out_file)
  print("New Rmarkdown post creat successfully!")
}
#>>>>>> new_rmd_post 函数 <<<<<<<<<<
# 写好模板文档后，你可以用这个函数来创建Rmarkdown文档
# 参数说明：
# post_name:     博文名（最好英文，显示不会乱码），比如我写这篇博文用的是
#                how-to-write-rmd-documents-in-hexo-system
#                意思不一定要对，只要能跟其他博文名字有区分就行了
# template_name: 模板名，起template.Rmd最好，因为每次写文章都会用到，
#                这样你创建的时候不用每次都指定模板的名字
# template_path: 模板文档的路径，默认当前工作路径
# post_path:     你想把生成的文档放在哪个路径，默认当前工作路径
new_rmd_post <- function(post_name=NULL,template_name="template.Rmd",
                         template_path=getwd(), post_path=getwd()){
  if(is.null(post_name)){
    stop("A post name must be given!")
  }
  input_file   <- paste(template_path,template_name, sep="/")
  current_time <- Sys.Date()
  out_file     <- paste0(current_time, "-",post_name,".Rmd")
  fl_content   <- readLines(input_file)
  writeLines(fl_content, out_file)
  print("New Rmarkdown post creat successfully!")
}
#>>>>> new_md_post 函数 <<<<<<<<<<
# 你可以用这个函数来将Rmd文档转换为markdown文档
# 需要安装knitr包，命令为 install.packages("knitr")
# 参数说明：
# post_name: 文章文档名，推荐使用 年-月-日-英文名 的方式
# template_name: 模板名，你需要转换的Rmd文档
# template_path: 模板文档的路径，默认当前工作路径
# post_path:     你想把生成的文档放在哪个路径，默认当前工作路径
# time_tag:      时间标签，如果你转换的文档没有年-月-日这种标记，
#                将time_tag设定为TRUE会自动在名字前加上
new_md_post <- function(template_name="template.Rmd",post_name=NULL,template_path=getwd(),
                        post_path="../_posts",time_tag=FALSE, new_fig_path=TRUE){
  if(is.null(post_name)){
    post_name <- gsub(pattern = "^(.*)\\.[Rr]md$", "\\1", x = template_name)
  }
  input_file   <- paste(template_path,template_name, sep="/")

  if(time_tag){
    current_time <- Sys.Date()
    out_file     <- paste0(post_path, "/", current_time, "-", post_name,".md")
    out_dir      <- paste0(post_path, "/", current_time, "-", post_name)
  }else{
    out_file     <- paste0(post_path, "/", post_name,".md")
    out_dir      <- paste0(post_path, "/", post_name)
  }
  # if new_fig_path is FALSE, use united figure path to sotre figures
  # if this variable is TRUE, create an independent directory for post
  if (new_fig_path){
    dir.create(out_dir, showWarnings = TRUE, recursive = TRUE)
    # add fig.path option to Rmd file
    fl_content   <- readLines(input_file)
    new_content  <- sub(pattern = "fig.path=\".*\"",
                        replacement = paste0("fig.path=\"", out_dir, "/\""), fl_content)
    writeLines(new_content, input_file)
  }

  knitr::knit(input = input_file, output = out_file)
  print("New markdown post creat successfully!")
}
