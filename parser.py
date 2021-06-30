#!/usr/bin/env python3

import csv
import numpy
import argparse
import json

def run_mb(output):
    result_codes = {}
    latency_list = []
    results_csv = csv.reader(open(output))
    for hit in results_csv:
        if hit[2] not in result_codes:
            result_codes[hit[2]] = 0
        result_codes[hit[2]] += 1
        latency_list.append(int(hit[1]))
    if latency_list:
        p95_latency = numpy.percentile(latency_list, 95)
        p99_latency = numpy.percentile(latency_list, 99)
        avg_latency = numpy.average(latency_list)
        return result_codes, p95_latency, p99_latency, avg_latency
    else:
        print("Warning: Empty latency result list, returning 0")
        return result_codes, 0, 0, 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    parser.add_argument("--runtime", required=True, type=int)
    args = parser.parse_args()
    result_codes, p95_latency, p99_latency, avg_latency = run_mb(args.output)
    requests_per_second = result_codes.get("200", 0) / args.runtime
    payload = {"requests_per_second": int(requests_per_second),
               "avg_latency": int(avg_latency),
               "latency_95pctl": int(p95_latency),
               "latency_99pctl": int(p99_latency)}
    payload.update(result_codes)
    print("Workload finished, results:")
    print(json.dumps(payload, indent=4))

if __name__ == '__main__':
    exit(main())