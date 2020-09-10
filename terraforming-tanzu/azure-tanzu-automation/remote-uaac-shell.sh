uaac target api.exelondemo.azure.tanzuapps.org:8443 --skip-ssl-validation
uaac token client get admin -s iD_E11DUTr2Gh_tZVw2aCjohbnHHOmXt
uaac user add pksadmin --emails pksadmin@example.com -p pivotal
uaac member add pks.clusters.admin pksadmin
