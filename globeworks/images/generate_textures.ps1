
$images = @(
    "A1"
    "A2"
    "B1"
    "B2"
    "C1"
    "C2"
    "D1"
    "D2"
)

$in_size = 21600
$divisions = 4
$crop_size = $in_size/4
$out_size = 1024

foreach ($prefix in $images) {
    for ($i=0; $i -lt $divisions; $i++) {
        for ($j=0; $j -lt $divisions; $j++) {
            $command = @(
                "magick"
                "world.topo.bathy.200401.3x21600x21600.$prefix.jpg"
                "-crop" 
                "${crop_size}x${crop_size}+$($i*$crop_size)+$($j*$crop_size)"
                "-resize"
                "${out_size}x${out_size}"
                "generated/${prefix}_$i$j.jpg"
            )
            $command_str = $command -join ' '
            echo $command_str
            iex $command_str
        }
    }
}