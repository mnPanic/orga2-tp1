#!/usr/bin/env bash
make clean
make main
if [ $? -ne 0 ]; then
  echo "ERROR: Error de compilacion."
  exit 1
fi
echo " "
echo "Corriendo tests"
./main
echo "Corriendo diferencias"
diff --color -pu salida.caso.propios.txt salida.propios.esperada.txt
if [ $? -ne 0 ]; then
  echo "ERROR: Hubo alguna diferencia"
else
  echo "OK!"
fi
