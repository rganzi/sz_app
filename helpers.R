## sz_app helpers.R

type <- function(plot.type, name, zone, x.min, x.max, y.min, y.max) {
        if(plot.type == "dens") {
                density.plot(name, zone, x.min, x.max, y.min, y.max)
        } else if(plot.type == "mod") {
                model.plot(name, zone, x.min, x.max, y.min, y.max)
        } else {
                print("error")
        }
}

## load all pitch data
pitch_data <- read.csv("data/pitchers.csv", header=TRUE, stringsAsFactors=FALSE)

## guideline strike zone dimensions
sz.bot <- 1.6
sz.top <- 3.6
sz.left <- -0.95
sz.right <- 0.95
sz.dim <- data.frame(cbind(px = c(sz.left, sz.right, sz.right, sz.left, sz.left), 
                           pz = c(sz.bot, sz.bot, sz.top, sz.top, sz.bot)))

## density.plot function
density.plot <- function(name, zone, x.min, x.max, y.min, y.max) {
        
        data <- subset(pitch_data, pitch_data$pitcher_name == name)
        
        # split left and right-handed batters
        data.l <- data[data$stand == "Left-handed Batter", ]
        data.r <- data[data$stand == "Right-handed Batter", ]
        
        # function for plotting densities of Balls and Called Strikes
        density <- function(e) {
        
                cs <- e[e$des == "Called Strike", ]
                ball <- e[e$des == "Ball", ]
        
                ggplot(rbind(data.frame(cs, group="Strike"), data.frame(ball, group="Ball")), aes(x=px,y=pz)) +
                        stat_density2d(geom="tile", aes(fill = group, alpha=(..density..)*1.67), n=30, contour=FALSE) +
                        geom_path(data=sz.dim, aes(px,pz), linetype=5, alpha=zone) +
                        scale_fill_manual(values=c("Strike"="orange", "Ball"="dodgerblue")) +
                        scale_color_manual(values=c("Strike"="#FF4719", "Ball"="#3333CC")) +
                        stat_density2d(aes(alpha=(..level..)*1.67, colour=group), contour=TRUE) +
                        xlim(x.min, x.max) + ylim(y.min, y.max) +
                        theme_minimal() + 
                        theme(aspect.ratio=1, strip.text.x=element_text(size=12), legend.position="bottom", 
                                plot.title=element_text(size=16), axis.title=element_text(size=12), 
                                axis.title.x=element_text(vjust=0), axis.title.y=element_text(vjust=1)) + 
                                xlab("Horizontal Location") + ylab("Height") +
                        guides(fill=guide_legend(""), alpha="none", color="none")
        }

p1 <- density(data.l) + ggtitle("Left-handed Batters")
p2 <- density(data.r) + ggtitle("Right-handed Batters")
grid.arrange(p1, p2, ncol=2)

}

## model.plot function

model.plot <- function(name, zone, x.min, x.max, y.min, y.max) {
        
        # subset only called pitches
        data <- subset(pitch_data, pitch_data$pitcher_name == name)
        
        # split left and right-handed batters
        data.l <- data[data$stand == "Left-handed Batter", ]
        data.r <- data[data$stand == "Right-handed Batter", ]
        
        # fit model, predict strikezone boundaries
        pred <- function(d) {
                
                aspect.ratio <- (max(d$px)-min(d$px))/(max(d$pz)-min(d$pz))
                d$des <- as.factor(d$des)
                
                # fit gam model
                fit <- gam(data=d, des ~ lo(px, span=.5*aspect.ratio, degree=1) + 
                                       lo(pz, span=.5, degree=1), family=binomial(link="logit"))
                
                # set up matrices for prediction
                myx.gam <- matrix(data=seq(from=-2, to=2, length=30), nrow=30, ncol=30)
                myz.gam <- t(matrix(data=seq(from=0,to=5, length=30), nrow=30, ncol=30))
                fitdata.gam <- data.frame(px=as.vector(myx.gam), pz=as.vector(myz.gam))
                
                # predict strikezone boundaries
                mypredict.gam <- predict(fit, fitdata.gam, type="response")
                mypredict.gam <- matrix(mypredict.gam, nrow=c(30,30))
                
                df <- data.frame(fitdata.gam, z=as.vector(mypredict.gam))
                df
        }
        
        df.l <- pred(data.l)
        df.r <- pred(data.r)        
        
        model <- function(df) {
                # model plot -- polygons from stat_contour
                ggplot(df, aes(x=px, y=pz)) +
                        stat_contour(geom="polygon", bins=8, aes(z=z, fill=..level..)) +
                        scale_fill_gradientn(colours = topo.colors(10), guide=guide_colorbar(title="P(Strike)", barwidth=16, nbin=4, draw.llim=TRUE, draw.ulim=TRUE)) +
                        geom_path(data=sz.dim, aes(px, pz), colour="black", alpha=zone, linetype=5) +
                        xlim(x.min, x.max) + ylim(y.min, y.max) +
                        theme_minimal() +
                        theme(aspect.ratio=1, strip.text.x=element_text(size=12), legend.position="bottom", 
                                plot.title=element_text(size=16), axis.title=element_text(size=12), 
                                axis.title.x=element_text(vjust=0), axis.title.y=element_text(vjust=1)) + 
                                xlab("Horizontal Location") + ylab("Height")
                }
        
        q1 <- model(df.l) + ggtitle("Left-handed Batters")
        q2 <- model(df.r) + ggtitle("Right-handed Batters")
        grid.arrange(q1, q2, ncol=2)
}