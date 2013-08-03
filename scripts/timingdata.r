timings <- function(file) {
    table <- read.table(file, col.names=c("parser", "time", "length"))
    extractparsers(table)
}

extractparsers <- function(table) {
    list(raw=table, caterpillar=parserselect(table, "caterpillar"),
                    danish=parserselect(table, "danish"),
                    norwegian=parserselect(table, "norwegian"),
                    swedish=parserselect(table, "swedish"))
}

parserselect <- function(table, extract) {
    attach(table)
    retval <- data.frame(time=time[parser == extract], length=length[parser == extract])
    detach(table)

    retval
}

prunetimes <- function(table, cutoff=20) {
    attach(table)
    indices = length <= 20
    pruned <- data.frame(parser=parser[indices], length=length[indices], time=time[indices])
    detach(table)

    extractparsers(pruned)
}

slicetimes <- function(frame, func) {
    f <- ordered(frame$length)
    tapply(frame$time, f, func)
}

plottimes <- function(frame, title="") {
    means <- slicetimes(frame, mean)
    medians <- slicetimes(frame, median)
    xlim = max(frame$length)
    ylim = max(means, medians)

    par(mfrow=c(2,1))
    plot(dimnames(means)[[1]], means, col="red", xlim=c(0, xlim), ylim=c(0, ylim), main=title,
        xlab="Sentence length", ylab="Annotation time")
    points(dimnames(medians)[[1]], medians, col="blue")
    legend("topright", c("Mean", "Median"),
                   col=c("red",  "blue"),
                   pch=c( 1,      1))

    hist(frame$length, main="", xlab="Sentence length",
        breaks=1:max(frame$length))
}

plotfunc <- function(frame, func, title="") {
    c <- slicetimes(frame$caterpillar, func)
    d <- slicetimes(frame$danish, func)
    n <- slicetimes(frame$norwegian, func)
    s <- slicetimes(frame$swedish, func)
    xlim <- max(frame$caterpillar$length, frame$norwegian$length,
        frame$norwegian$length, frame$swedish$length)
    ylim <- max(c, d, n, s)

    plot(dimnames(c)[[1]], c, type="l", col="red", xlim=c(0, xlim), ylim=c(0, ylim), main=title,
        xlab="Sentence length", ylab="Annotation time")
    lines(dimnames(d)[[1]], d, col="blue")
    lines(dimnames(n)[[1]], n, col="green")
    lines(dimnames(s)[[1]], s, col="black")

    legend("topright", c("Caterpillar", "Danish", "Norwegian", "Swedish"),
                   col=c("red",         "blue",   "green",     "black"),
                   lty=c( 1,             1,        1,           1))
}

# vim: ft=r
