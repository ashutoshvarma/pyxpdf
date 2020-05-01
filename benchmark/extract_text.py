# coding=utf-8

import os
from time import time
from pyxpdf import Document

BENCH_DIR = os.path.dirname(os.path.realpath(__file__))
ROOT_DIR = os.path.dirname(BENCH_DIR)
SMAPLES_DIR = os.path.join(os.path.join(ROOT_DIR, 'samples'))

mandarin_pdf = os.path.join(SMAPLES_DIR, 'nonfree', 'mandarin.pdf')
dmca_pdf = os.path.join(SMAPLES_DIR, 'nonfree', 'dmca.pdf')

def run():
    t0 = time()

    text1 = Document(mandarin_pdf).text()
    text2 = Document(dmca_pdf).text()

    tk = time()
    return tk - t0


def main(n):
    # run()  # warmup
    times = []
    for i in range(n):
        times.append(run())
    return times


if __name__ == "__main__":
    import optparse
    import util
    parser = optparse.OptionParser(
        usage="%prog [options]",
        description="Test the performance of text extraction.")
    util.add_standard_options_to(parser)
    options, args = parser.parse_args()

    util.run_benchmark(options, options.num_runs, main)