BEGIN { OFS = "\t" }

NF > 0 {
    $7 = $1 - 1;
    $8 = "ADV"; # Most common dependency relation
}

{ print }
