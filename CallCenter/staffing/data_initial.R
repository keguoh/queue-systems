### get the arrival time and service time for Nov/Dec ###
dat1 <- read.table(file = "C:/Users/Keguo/Dropbox/GitHub/queue-systems/CallCenter/november.txt", header = T)
q_start1 <- strptime(paste(dat1$date, dat1$q_start), format='%y%m%d %H:%M:%S')
dat1$arrival_day_of_month <- as.numeric(format(q_start1, '%d'))
dat1$arrival_day_of_week <- (dat1$arrival_day_of_month) %% 7 
dat1$month <- 11

dat2 <- read.table(file = "C:/Users/Keguo/Dropbox/GitHub/queue-systems/CallCenter/december.txt", header = T)
q_start2 <- strptime(paste(dat2$date, dat2$q_start), format='%y%m%d %H:%M:%S')
dat2$arrival_day_of_month <- as.numeric(format(q_start2, '%d'))
dat2$arrival_day_of_week <- (dat2$arrival_day_of_month + 2) %% 7 
dat2$month <- 12
dat <- rbind(dat1, dat2)
## we only need "PS" type service and q_start greater than 0 with service time greater than 0 ##
## "PS" type
dat <- split(dat, dat$type )$PS
dat <- dat[dat$ser_time > 0 | dat$q_time > 0,]


q_start <- strptime(paste(dat$date, dat$q_start), format='%y%m%d %H:%M:%S')
q_start_hour_of_day <- as.numeric(format(q_start, '%H'))
q_start_min_of_hour <- as.numeric(format(q_start, '%M'))
q_start_sec_of_min <- as.numeric(format(q_start, '%S'))
q_start_sec_of_day <- (q_start_hour_of_day*3600 
                            + q_start_min_of_hour*60
                            + q_start_sec_of_min)
ser_start <- strptime(paste(dat$date, dat$ser_start), format='%y%m%d %H:%M:%S')
ser_start_hour_of_day <- as.numeric(format(ser_start, '%H'))
ser_start_min_of_hour <- as.numeric(format(ser_start, '%M'))
ser_start_sec_of_min <- as.numeric(format(ser_start, '%S'))
ser_start_sec_of_day <- (ser_start_hour_of_day*3600 
                            + ser_start_min_of_hour*60
                            + ser_start_sec_of_min)


# valid dat (positive service time or queue time)
dat$arrival_sec_of_day = -1
for(i in 1:nrow(dat)){
  if(dat$q_time[i] > 0){
    dat$arrival_sec_of_day[i] <- q_start_sec_of_day[i]
  } else{dat$arrival_sec_of_day[i] <- ser_start_sec_of_day[i]}
}
dat$arrival_min_of_hour = dat$arrival_sec_of_day%/%60%%60
dat$arrival_hour_of_day = dat$arrival_sec_of_day%/%(60*60)

# delete some data after midnight and before 7 am
dat <- dat[dat$arrival_sec_of_day >= 7*60*60, ]
write.csv(dat, file='data.csv')
workdat <- dat[dat$arrival_day_of_week<5, ]
write.csv(workdat, file='work_data.csv')
write.table(workdat[, c('arrival_sec_of_day')], row.names = F, col.names = F,
            file = 'arrival_pool.csv')


# service time
serviceTime <- dat$ser_time[dat$ser_time > 0]
length(serviceTime)
hist(serviceTime, breaks = 1000, xlim = c(0,1000))
write.table(workdat$ser_time[workdat$ser_time > 0], row.names = F, col.names = F,
            file = 'serv_time_pool.csv')

#patient time
patientTime <- dat$q_time[dat$outcome=='HANG' & dat$q_time>0]
length(patientTime)
hist(patientTime, breaks=60)
write.table(workdat$q_time[workdat$outcome=='HANG' & workdat$q_time>0], 
            row.names = F, col.names = F, file = 'patient_time_pool.csv')
