import subprocess
import sys


#ip  = raw_input()



def cambiaRedPor():
#    print 'Argument List:', str(sys.argv)
#    ip = "ping -c4 " + str(sys.argv)

    cmd = str(sys.argv)
#    cmd = "216.58.211.228"
    cms = "freegeoip.net/csv/" + cmd
 
 
    p = subprocess.Popen(["curl",cms], stderr=subprocess.PIPE)
    while True:
        out = p.stderr.read(1)
        if out == '' and p.poll() != None:
           break
        if out != '':
           sys.stdout.write(out)
           sys.stdout.flush()




cambiaRedPor()
