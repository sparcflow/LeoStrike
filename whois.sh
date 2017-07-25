#!/bin/bash
echo "ip;dns;owner;netname;country;person;email;created;last_modified" > output.csv
while read -r ip
do
    echo $ip
    if [[ $ip =~ [a-zA-Z.] ]] ; then
        dns=$ip
        ip=`dig +short $ip |grep -m 1 -E "[0-9]{2,3}\..*"`
    else
       dns=`resolveip $ip | cut -d" " -f 6`
    fi
    
    whois $ip > whoisip
    owner=`cat whoisip | grep -i -m 1 "owner:" | sed 's/owner:       //g'`
    netname=`cat whoisip | grep -i -m 1 "netname:" | sed 's/netname:        //g'`
    descr=`cat whoisip | grep -i -m 1 "descr:" | sed 's/descr:          //g'`
    country=`cat whoisip | grep -i -m 1 "country"  |  sed 's/country:     //g'`
    person=`cat whoisip | grep -i -m 1 "person:"  | sed 's/person:      //g'`
    created=`cat whoisip | grep -i -m 1 "created" | sed 's/created:        //g'`
    last_modified=`cat whoisip | grep -i -m 1 "last-modified:" | sed 's/last-modified:  //g'`
    email=`cat whoisip | grep -m 1 "email:" | sed 's/email:      //g'`
    
    if [[  -z $created ]] ; then
        created=`cat whoisip | grep -i -m 1 "RegDate" | sed 's/RegDate:        //g'`      
    fi
    
    if [[  -z $last_modified ]] ; then
        last_modified=`cat whoisip | grep -i -m 1 "updated" | sed 's/Updated:        //g'`      
    fi
    if [[ -z $last_modified ]]; then
        last_modified=`cat whoisip | grep -i -m 1 "changed" | sed 's/changed: //g'`
    fi
    echo $ip";"$dns";"$owner";"$netname";"$country";"$person";"$email";"$created";"$last_modified #>> output.csv
    echo $ip";"$dns";"$owner";"$netname";"$country";"$person";"$email";"$created";"$last_modified >> output.csv
done <ips.txt
