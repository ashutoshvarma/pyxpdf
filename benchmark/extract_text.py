# coding=utf-8

from time import time
from pyxpdf import Document


def run():
    t0 = time()

    text1 = Document("samples/nonfree/mandarin.pdf").text()
    text2 = Document("samples/nonfree/dmca.pdf").text()

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