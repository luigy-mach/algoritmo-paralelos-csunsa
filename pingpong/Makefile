EXECS=pingpong
MPICC=mpicc

all: ${EXECS}

pingpong: pingpong1.c
    ${MPICC} -o pingpong pingpong1.c

clean:
    rm ${EXECS}
