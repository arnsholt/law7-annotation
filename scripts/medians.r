source("scripts/timingdata.r")

medians <- function(data) {
    attach(data)
    frame <- list(caterpillar=slicetimes(caterpillar, median),
                  danish=slicetimes(danish, median),
                  norwegian=slicetimes(norwegian, median),
                  swedish=slicetimes(swedish, median))
    detach(data)

    frame
}

writeit <- function(med, where) {
    write(t(matrix(c(as.numeric(dimnames(med$caterpillar)[[1]]),
                     as.numeric(med$caterpillar)),
                   ncol=2)),
          file=where, ncolumns=2)

    write("", file=where, append=T)
    write("", file=where, append=T)

    write(t(matrix(c(as.numeric(dimnames(med$danish)[[1]]),
                     as.numeric(med$danish)),
                   ncol=2)),
          file=where, ncolumns=2, append=T)

    write("", file=where, append=T)
    write("", file=where, append=T)

    write(t(matrix(c(as.numeric(dimnames(med$norwegian)[[1]]),
                     as.numeric(med$norwegian)),
                   ncol=2)),
          file=where, ncolumns=2, append=T)

    write("", file=where, append=T)
    write("", file=where, append=T)

    write(t(matrix(c(as.numeric(dimnames(med$swedish)[[1]]),
                     as.numeric(med$swedish)),
                   ncol=2)),
          file=where, ncolumns=2, append=T)
}

odin <- prunetimes(timings("odin.dat")$raw)
thor <- prunetimes(timings("thor.dat")$raw)

# TODO: Prune data set to only contain length <= 20 sents.

writeit(medians(odin), "medians-odin.dat")
writeit(medians(thor), "medians-thor.dat")

# vim: ft=r
