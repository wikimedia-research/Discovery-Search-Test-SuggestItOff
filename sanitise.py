# Should be done through python3
import json
import re
import argparse
import csv

parser = argparse.ArgumentParser(description='Process Cirrus A/B test logfiles.')
parser.add_argument("in_file", metavar="in_file", type=str, help="The input file, unsanitised")
parser.add_argument("geofile", metavar="geofile", type=str, help="The path to the -Country GeoIPv2 file")
parser.add_argument("out_file", metavar="out_file", type=str, help="The output file, now sanitised!")
args = parser.parse_args()

json_regex = re.compile("{.*");

def sanitise_line(line):
  match_result = re.search(json_regex, line);
  json_blob = json.loads(match_result.group(0));
  output = {
    'test_group' : json_blob['tests']['suggest-confidence'],
    'results'    : json_blob['hits'],
    'project'    : json_blob['wiki'],
    'source'     : json_blob['source'],
    'browser'    : json_blob['userAgent'],
    'country'    : json_blob['ip']
  }
  return output;

def write_file(results, filepath):
  with open(filepath, "wt") as tsv_file:
    write_obj = csv.writer(tsv_file, delimiter = "\t");
    write_obj.writerow(["test_group","ip","project","user_agent","results", "source"]);
    for result in results:
      converted_result = [];
      for key in result:
        converted_result.append(result[key]);
      write_obj.writerow(converted_result);
      
    
  

connection = open("CirrusSearchUserTesting.log");
output = [];
for line in connection:
  try:
      output.append(sanitise_line(line))
  except:
      print(".")
    
  

write_file(output, args.out_file);
exit();
