import csv

print "start"

input = open('admin123simplemedium-attr.csv', 'rb')
output = open('admin123simplemedium-attr-clean.csv', 'wb')
writer = csv.writer(output)
for row in csv.reader(input):
##    print row
    if row != ['', '', '']:
        writer.writerow(row)
input.close()
output.close()

print "done"
