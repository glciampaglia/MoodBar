# Mixed model regression using glmmADMB. 

require(glmmADMB) # glmm.admb

EC <- read.table('data/ec_mb.tsv', sep='\t', header=T, stringsAsFactors=T)
# relevel factors
EC <- within(EC, 
             user_id<-factor(user_id),
             treatment<-factor(treatment), 
             namespace<-relevel(namespace, ref="Main"),
             browser<-relevel(browser, ref="msie"),
             os<-relevel(os, ref="win"),
             mood<-relevel(mood, ref="happy"),
             )
levels(EC$treatment)<-c("Feedback", "Feed+Resp.", "Feed+Useful")
summary(EC)

# rescale control variables
EC <- within(EC,
             cohort<-scale(cohort),
             is_editing<-scale(is_editing),
             feedback_lag<-scale(feedback_lag),
             ept_lag<-scale(ept_lag),
             feedback_editcount<-scale(feedback_editcount),
             feedback_len<-scale(feedback_len),
             num_feedbacks<-scale(num_feedbacks)
             )

# XXX Does not converge
 m.uncmean <- glmmadmb(editcount ~ I(age - 1), random = ~ age | user_id, data=EC, family="nbinom")

