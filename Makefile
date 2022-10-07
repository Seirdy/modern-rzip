
# Copyright (C) Kamila Szewczyk 2022

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CC=clang
CXX=clang++
CCONFIG=-Ivendor/zpaq -Ivendor/lz4/lib -Ivendor/zstd/lib -Ivendor/fast-lzma2 \
        -Ivendor/bzip3/include -Ivendor/ppmd_sh -Ivendor/ppmd_sh/libpmd \
		-Iinclude -DZSTD_DISABLE_ASM
FLAGS=-g3 -O3 -march=native -mtune=native $(CCONFIG)
PROGRAM=mrzip

MRZIP_SOURCES=$(wildcard src/*.c)
MRZIP_OBJECTS=$(MRZIP_SOURCES:.c=.o)

ZSTD_SOURCES=$(wildcard vendor/zstd/lib/common/*.c) \
             $(wildcard vendor/zstd/lib/compress/*.c) \
			 $(wildcard vendor/zstd/lib/decompress/*.c)
ZSTD_OBJECTS=$(ZSTD_SOURCES:.c=.o)

FLZMA2_SOURCES=$(wildcard vendor/fast-lzma2/*.c)
FLZMA2_OBJECTS=$(FLZMA2_SOURCES:.c=.o)

MRZIP_LIBS=vendor/cxx_glue.o vendor/zpaq/libzpaq.o \
           vendor/lz4/lib/lz4.o vendor/lz4/lib/lz4hc.o \
		   vendor/bzip3/src/libbz3.o \
		   $(ZSTD_OBJECTS) $(FLZMA2_OBJECTS)

$(PROGRAM): $(MRZIP_OBJECTS) $(MRZIP_LIBS)
	$(CXX) $(FLAGS) -o $@ $^ -lm -pthread -lpthread -lgcrypt -lgpg-error -static

%.o: %.c
	$(CC) $(FLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) $(FLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(PROGRAM) $(MRZIP_OBJECTS) $(MRZIP_LIBS)
