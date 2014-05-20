python
import sys
from os.path import expanduser
sys.path.insert(0, expanduser('~/.gdb'))
from eigen.printers import *
register_eigen_printers (None)
end
