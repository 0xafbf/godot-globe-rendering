

function Get-File {
    param (
        [string] $QuadKey
    )

    $source = "http://ecn.t0.tiles.virtualearth.net/tiles/a${QuadKey}.jpeg?g=12775"
    $destination = "./a${QuadKey}.jpg"

    Write-Host "downloading $source to $destination"
    Invoke-WebRequest $source -OutFile $destination
}


function Get-Files {
    param (
        [string] $Base,
        [int] $Recurse
    )
    Get-File "${Base}0"
    Get-File "${Base}1"
    Get-File "${Base}2"
    Get-File "${Base}3"

    $NextRecurse = $Recurse - 1
    if ($NextRecurse -ge 0) {
        Get-Files "${Base}0" $NextRecurse
        Get-Files "${Base}1" $NextRecurse
        Get-Files "${Base}2" $NextRecurse
        Get-Files "${Base}3" $NextRecurse
        
    }
}

Get-Files -Base "" -Recurse 2


