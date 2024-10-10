# echo $(($(brightnessctl g) / 255 * 100 ))
brightness=$(brightnessctl g)
echo "x=$brightness / 255 * 100;scale=0; x / 1" | bc -l