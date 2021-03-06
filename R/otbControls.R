
#'@title  Usually for internally usage, initializes and set up  access to the 'OTB' command line interface
#'@name setenvOTB
#'@description  Initializes and set up  access to the 'OTB' command line interface
#'  
#'@param bin_OTB  string contains the path to the 'OTB' binaries
#'@param root_OTB string contains the full string to the root folder
#'  containing the 'OTB' installation'
#'@return Adds 'OTB' pathes to the enviroment and creates the variable global string variable \code{otbCmd}, that contains the path to the 'OTB' binaries.
#'@export setenvOTB
#'  
#'@examples
#' \dontrun{
#'## example for the most common default OSGeo4W64 installation of OTB
#'setenvOTB(bin_OTB = "C:\\OSGeo4W64\\bin\\",
#'           root_OTB = "C:\\OSGeo4W64")
#'}

setenvOTB <- function(bin_OTB = NULL, root_OTB = NULL){
  # check if running on a HRZMR Pool PC
  if (!exists("GiEnv")) GiEnv <- new.env(parent=globalenv()) 
  if (substr(Sys.getenv("COMPUTERNAME"),1,5) == "PCRZP") {
    bin_OTB <- checkPCDomain("otb")   
    Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = GiEnv)
  } else {
    # (R) set pathes  of otb modules and binaries depending on OS  
    if (Sys.info()["sysname"] == "Windows") {
      #makGlobalVar("otbPath", bin_OTB)
      add2Path(bin_OTB)
      Sys.setenv(OSGEO4W_ROOT = root_OTB)
      Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = GiEnv)
    }
    #else {
    #  makGlobalVar("otbPath", "(usr/bin/")
    #}
  }
  return(bin_OTB)
}

#'@title Search recursively for valid 'OTB' installation(s) on a 'Windows' OS
#'@name searchOTBW
#'@description  Search for valid 'OTB' installations on a 'Windows' OS
#'@param DL drive letter default is "C:"
#'@param quiet boolean  switch for supressing console messages default is TRUE
#'@return A dataframe with the 'OTB' root folder(s) the version name(s) and the installation type(s).
#'@author Chris Reudenbach
#'@export searchOTBW
#'@keywords internal
#'
#'@examples
#' \dontrun{
#' # get all valid OTB installation folders and params
#' searchOTBW()
#' }

searchOTBW <- function(DL = "C:",
                       quiet=TRUE) {
  if (DL=="default") DL <- "C:"
  if (Sys.info()["sysname"] == "Windows") {
    if (!exists("GiEnv")) GiEnv <- new.env(parent=globalenv()) 
    if (substr(Sys.getenv("COMPUTERNAME"),1,5) == "PCRZP") {
      defaultOtb <- shQuote("C:\\Program Files\\QGIS 2.14\\bin")
      otbInstallations <- data.frame(instDir = shQuote("C:\\Program Files\\QGIS 2.14\\bin"), installation_type = "osgeo4wOTB",stringsAsFactors = FALSE)
      Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = GiEnv)
    } else {
      # trys to find a osgeo4w installation on the whole C: disk returns root directory and version name
      # recursive dir for otb*.bat returns all version of otb bat files
      if (!quiet) cat("\nsearching for Orfeo Toolbox installations - this may take a while\n")
      if (!quiet) cat("For providing the path manually see ?searchOTBW \n")
      raw_OTB <- system(paste0("cmd.exe"," /c dir /B /S ",DL,"\\","otbcli.bat"),intern=TRUE)
      if (!grepl(DL,raw_OTB)) stop("\n At ",DL," no OTB installation found")
      # trys to identify valid otb installations and their version numbers
      otbInstallations <- lapply(seq(length(raw_OTB)), function(i){
        # convert codetable according to cmd.exe using type
        batchfile_lines <- raw_OTB[i]
        installerType <- ""
        # if the the tag "OSGEO4W64" exists set installation_type
        if (length(unique(grep(paste("OSGeo4W64", collapse = "|"), raw_OTB[i], value = TRUE))) > 0) {
          root_dir <- unique(grep(paste("OSGeo4W64", collapse = "|"), raw_OTB[i], value = TRUE))
          root_dir <- substr(root_dir,1, gregexpr(pattern = "otbcli.bat", root_dir)[[1]][1] - 1)
          installDir <- substr(root_dir,1, gregexpr(pattern = "bin", root_dir)[[1]][1] - 2)
          installerType <- "osgeo4w64OTB"
        }    
        
        # if the the tag "OSGEO4W" exists set installation_type
        else if (length(unique(grep(paste("OSGeo4W", collapse = "|"), raw_OTB[i], value = TRUE))) > 0) {
          root_dir <- unique(grep(paste("OSGeo4W", collapse = "|"), raw_OTB[i], value = TRUE))
          root_dir <- substr(root_dir,1, gregexpr(pattern = "otbcli.bat", root_dir)[[1]][1] - 1)
          installDir <- substr(root_dir,1, gregexpr(pattern = "bin", root_dir)[[1]][1] - 2)
          installerType <- "osgeo4wOTB"
        }
        # if the the tag "QGIS" exists set installation_type
        else if (length(unique(grep(paste("QGIS", collapse = "|"), batchfile_lines, value = TRUE))) > 0) {
          root_dir <- unique(grep(paste("QGIS", collapse = "|"), raw_OTB[i], value = TRUE))
          root_dir <- substr(root_dir,1, gregexpr(pattern = "otbcli.bat", root_dir)[[1]][1] - 1)
          installDir <- substr(root_dir,1, gregexpr(pattern = "bin", root_dir)[[1]][1] - 2)
          installerType <- "qgisOTB"
        }
        # if the the tag "OTB-" exists set installation_type
        else if (length(unique(grep(paste("OTB-", collapse = "|"), batchfile_lines, value = TRUE))) > 0) {
          root_dir <- unique(grep(paste("OTB-", collapse = "|"), raw_OTB[i], value = TRUE))
          root_dir <- substr(root_dir,1, gregexpr(pattern = "otbcli.bat", root_dir)[[1]][1] - 1)
          installDir <- substr(root_dir,1, gregexpr(pattern = "bin", root_dir)[[1]][1] - 2)
          installerType <- "OTB"
        }
        # put the existing GISBASE directory, version number  and installation type in a data frame
        data.frame(binDir = root_dir, baseDir = installDir, installation_type = installerType, stringsAsFactors = FALSE)
      }) # end lapply
      # bind the df lines
      otbInstallations <- do.call("rbind", otbInstallations)
    }
  } else {otbInstallations <- "Sorry no Windows system..." }
  return(otbInstallations)
}

#'@title Search recursively for valid 'OTB' installation(s) on a 'Windows' OS
#'@name searchOTBX
#'@description  Search for valid 'OTB' installations on a 'Windows' OS
#'@param MP drive letter default is "C:"
#'@param quiet boolean  switch for supressing messages default is TRUE
#'@return A dataframe with the 'OTB' root folder(s) the version name(s) and the installation type(s).
#'@author Chris Reudenbach
#'@export searchOTBX
#'@keywords internal
#'
#'@examples
#' \dontrun{
#' # get all valid OTB installation folders and params
#' searchOTBX()
#' }
searchOTBX <- function(MP = "/usr",
                       quiet=TRUE) {
  if (MP=="default") MP <- "/usr"
    if (!exists("GiEnv")) GiEnv <- new.env(parent=globalenv()) 
      # trys to find a osgeo4w installation at the mounting point  disk returns root directory and version name
      # recursive dir for otb*.bat returns all version of otb bat files
      if (!quiet) cat("\nsearching for Orfeo Toolbox installations - this may take a while\n")
      if (!quiet) cat("For providing the path manually see ?searchOTBX \n")
      raw_OTB <- system2("find", paste("/usr"," ! -readable -prune -o -type f -executable -iname 'otbcli' -print"),stdout = TRUE)
      if (!grepl(MP,raw_OTB)) stop("\n At ",MP," no OTB installation found")
      # trys to identify valid otb installations and their version numbers
      otbInstallations <- lapply(seq(length(raw_OTB)), function(i){
      
      # if the the tag "OSGEO4W64" exists set installation_type
          root_dir <- substr(raw_OTB[i],1, gregexpr(pattern = "otbcli", raw_OTB[i])[[1]][1] - 1)
        # put the existing GISBASE directory, version number  and installation type in a data frame
        data.frame(binDir = root_dir,otbCmd = paste0(root_dir,"otbcli"), stringsAsFactors = FALSE)
      }) # end lapply
      # bind the df lines
      otbInstallations <- do.call("rbind", otbInstallations)
    
  
  return(otbInstallations)
}

#'@title Search recursivly existing 'Orfeo Toolbox' installation(s) at a given drive/mountpoint 
#'@name findOTB
#'@description  Provides an  list of valid 'OTB' installation(s) 
#'on your 'Windows' system. There is a major difference between osgeo4W and 
#'stand_alone installations. The functions trys to find all valid 
#'installations by analysing the calling batch scripts.
#'@param searchLocation drive letter to be searched, for Windows systems default
#' is \code{C:}, for Linux systems default is \code{/usr}.
#'@param quiet boolean  switch for supressing console messages default is TRUE
#'@return A dataframe with the 'OTB' root folder(s),  and command line executable(s)
#'@author Chris Reudenbach
#'@export findOTB
#'
#'@examples
#' \dontrun{
#' # find recursively all existing 'Orfeo Toolbox' installations folders starting 
#' # at the default search location
#' findOTB()
#' }
findOTB <- function(searchLocation = "default",
                    quiet=TRUE) {
  
  if (Sys.info()["sysname"] == "Windows") {
    if (searchLocation=="default") searchLocation <- "C:"
    if (searchLocation %in% paste0(LETTERS,":"))
      link = link2GI::searchOTBW(DL = searchLocation,                     
                                 quiet=TRUE)  
    else stop("You are running Windows - Please choose a suitable searchLocation argument that MUST include a Windows drive letter and colon" )
  } else {
    if (searchLocation=="default") searchLocation <- "/usr"
    if (grepl(searchLocation,pattern = ":"))  stop("You are running Linux - please choose a suitable searchLocation argument" )
    else link = link2GI::searchOTBX(MP = searchLocation,
                                    quiet=TRUE)
  }
  return(link)
}
