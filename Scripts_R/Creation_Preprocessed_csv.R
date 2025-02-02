#' @name Creation_Preprocessed_csv
#' 

Creation_Preprocessed_csv <- function(files){
  
  #Initialisation
  filtered_total_acc_x <- data.frame()
  
  filtered_total_acc_y <- data.frame()
  
  filtered_total_acc_z <- data.frame()
  
  gravity_acc_x <- data.frame()
  
  gravity_acc_y <- data.frame()
  
  gravity_acc_z <- data.frame()
  
  Labels <- data.frame()
  
  #Preprocessing the data from each file
  
  for (i in 1:length(files)){
    binfile <- files[i]
  
    print(paste0("---Beginning preprocessing of ",binfile," ---"))
    
    #Importation des donnees
    acc_data <- import_df_GENEA(binfile)
    df <- as_tibble(acc_data)
    wave <- df[,c(2,3,4)] 
    
    #Noise filtering
    
    bf <- butter(4,W=0.4,type="low") # 15Hz low pass filtering Butterworth
    
    resx <- signal::filter(bf,wave$x)
    resy <- signal::filter(bf,wave$y)
    resz <- signal::filter(bf,wave$z)
    
    filtered_total_acc <- data.frame(resx,resy,resz) # Acceleration totale
    
    # Visualize Noise Filtering
    diff <- wave$x - resx
    
    plot(diff[400:1000], col='gray', main="Low-pass filtering",type='l')
    lines(wave$x[400:1000], col='red', main="Original signal",type='l')
    lines(resx[400:1000], col='blue', main="Filtered low-pass with cutoff frequency 15Hz",type='l')
    
    
    #Gravity filtering
    sampling_rate <- 75
    nyq_freq <- sampling_rate/2.0
    
    bf_gravity <- butter(3,W=0.008,type="low") # 0.3 Hz very low pass filtering to get the gravity
    
    res_gravity_x <- signal::filter(bf_gravity,wave$x)
    res_gravity_y <- signal::filter(bf_gravity,wave$y)
    res_gravity_z <- signal::filter(bf_gravity,wave$z)
    
    Gravity_acc <- data.frame(res_gravity_x,res_gravity_y,res_gravity_z) #Gravity acceleration
    
    
    #Visualize Gravity Filtering
    diff_gravity <- wave$z - res_gravity_z
    
    plot(diff_gravity[4000:10000], col='gray', main="Low-pass Gravity filtering",type='l')
    lines(wave$z[4000:10000], col='red', main="Original signal",type='l')
    lines(res_gravity_z[4000:10000], col='blue', main="Filtered low-pass with cutoff frequency 0.3 Hz",type='l')
    
    
    #Creation des datasets
    
    #Ligne par ligne
    N=length(filtered_total_acc$resx)
    taille_segment <- 750
    
    
    q <- N%/%taille_segment  
    q <- 2*(q-5)   # nombre de segments
    
    print(paste0("--- Cr�ation de ",q," segments ---"))
    
    for (i in 1:q){
      
      #Acc selon x
      segment_x <- filtered_total_acc$resx[seq(1+(10+i)*375,(12+i)*375)]
      row_x <- as.data.frame(t(segment_x))
      
      filtered_total_acc_x <- rbind(filtered_total_acc_x,row_x)
      
      #Acc selon y
      segment_y <- filtered_total_acc$resy[seq(1+(10+i)*375,(12+i)*375)]
      row_y <- as.data.frame(t(segment_y))
      filtered_total_acc_y <- rbind(filtered_total_acc_y,row_y)
      
      #Acc selon z
      segment_z <- filtered_total_acc$resz[seq(1+(10+i)*375,(12+i)*375)]
      row_z <- as.data.frame(t(segment_z))
      filtered_total_acc_z <- rbind(filtered_total_acc_z,row_z)
      
      #Gravity selon x
      segment_grav_x <- Gravity_acc$res_gravity_x[seq(1+(10+i)*375,(12+i)*375)]
      row_grav_x <- as.data.frame(t(segment_grav_x))
      gravity_acc_x <- rbind(gravity_acc_x,row_grav_x)
      
      #Gravity selon y
      segment_grav_y <- Gravity_acc$res_gravity_y[seq(1+(10+i)*375,(12+i)*375)]
      row_grav_y <- as.data.frame(t(segment_grav_y))
      gravity_acc_y <- rbind(gravity_acc_y,row_grav_y)
      
      #Gravity selon z
      segment_grav_z <- Gravity_acc$res_gravity_z[seq(1+(10+i)*375,(12+i)*375)]
      row_grav_z <- as.data.frame(t(segment_grav_z))
      gravity_acc_z <- rbind(gravity_acc_z,row_grav_z)
    }
    
    #Creation des labels
    
    nb_labels <- q #nombre de labels � ajouter
    
    print(paste0("Nom du fichier : ",binfile))
    cat("Quel est le label : 'COURSE' ou 'MARCHE' ou 'SEDENTAIRE' ou 'SOMMEIL' ?")
    valeur <- toString(readline())
    
    labels_input <- rep(valeur,nb_labels)
    Labels <- rbind(Labels,as.data.frame(labels_input))
    
    print(paste0("...Preprocessing succesful for ",binfile))
  }
    
  
  #Ecriture des fichiers csv
  
  write.table(filtered_total_acc_x, file="Fichiers_csv/Filtered_total_acc_x.csv", row.names=FALSE, col.names=FALSE, sep=",")
  write.table(filtered_total_acc_y, file="Fichiers_csv/Filtered_total_acc_y.csv", row.names=FALSE, col.names=FALSE, sep=",")
  write.table(filtered_total_acc_z, file="Fichiers_csv/Filtered_total_acc_z.csv", row.names=FALSE, col.names=FALSE, sep=",")
  
  
  write.table(gravity_acc_x, file="Fichiers_csv/gravity_acc_x.csv", row.names=FALSE, col.names=FALSE, sep=",")
  write.table(gravity_acc_y, file="Fichiers_csv/gravity_acc_y.csv", row.names=FALSE, col.names=FALSE, sep=",")
  write.table(gravity_acc_z, file="Fichiers_csv/gravity_acc_z.csv", row.names=FALSE, col.names=FALSE, sep=",")
  
  write.table(Labels, file="Fichiers_csv/Labels.csv", row.names=FALSE, col.names=FALSE, sep=",")
  
  
  
}






