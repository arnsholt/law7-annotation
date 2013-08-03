BEGIN { OFS = "\t" }

NF > 0 {
    if($8 == "nobj" || $8 == "nobj???") {
        $8 = "PUTFYLL"
    }
}

{ print }
