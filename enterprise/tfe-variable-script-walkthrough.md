             H        H
          HHHH        HHH
      HHHHHHHH        HHHHH
   HHHHHHHHHH         HHHHH   H
 HHHHHHHHH            HHHHH   HHH
 HHHHHH      H        HHHHH   HHHHH   _  _         _    _  ___
 HHHHH     HHH        HHHHH   HHHHH  | || |__ _ __| |_ (_)/ __|___ _ _ _ __
 HHHHH   HHHHH        HHHHH   HHHHH  | __ / _` (_-< ' \| | (__/ _ \ '_| '_ \
 HHHHH   HHHHH        HHHHH   HHHHH  |_||_\__,_/__/_||_|_|\___\___/_| | .__/
 HHHHH   HHHHHHHHHHHHHHHHHH   HHHHH                                   |_|
 HHHHH   HHHHHHHHHHHHHHHHHH   HHHHH
 HHHHH   HHHHHHHHHHHHHHHHHH   HHHHH     
 HHHHH   HHHHH        HHHHH   HHHHH            
 HHHHH   HHHHH        HHH     HHHHH       
 HHHHH   HHHHH        H      HHHHHH              
   HHH   HHHHH            HHHHHHHHH
     H   HHHHH          HHHHHHHHH        
         HHHHH        HHHHHHHH                 
           HHH        HHHH
             H       
             
# TFE Operations Scripts
https://github.com/hashicorp/terraform-guides/tree/master/operations/variable-scripts

## Scripts to set and delete workspace variables
cd /Users/jray/Documents/GitHub/terraform-guides/operations/variable-scripts/

### edit variables.csv
cp /variables.csv /<worksapce name>-variables.csv
nano /<worksapce name>-variables.csv

- structure of variables.csv is *var-key;var-value;hcl true/false; secure true/false

AWS_DEFAULT_REGION;us-east-1;terraform;false;false
CONFIRM_DESTROY;1;env;false;false
AWS_ACCESS_KEY_ID;;env;false;true
AWS_SECRET_ACCESS_KEY;;env;false;true

## executing set-variables script
cd /Users/jray/Documents/GitHub/terraform-guides/operations/variable-scripts/

### set env vars
export TFE_TOKEN="<token with workspace privilege>"
export TFE_ORG="GLIC"
export TFE_ADDR="jray-ptfe.hashidemos.io"

### execute script
./set-variables.sh test-case-2 test-case-2-variables.csv