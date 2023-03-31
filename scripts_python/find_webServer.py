import requests

###
#    Uses requests to collect webserver information
###

headers = {
    'UserAgent': "Giffy discovery Agent /1.0",
    'Content-Type': 'application/json',
}

ips_list = list()
for num in range(0, 35):
    ips_list.append(f'192.168.1.{num}')

ports_list = list()
for port in range(443, 444):
    ports_list.append(f':{port}')

ports_list = [80, 443, 3306, 5000]


def scan_web(ips_list, ports_list):
    for i in range(len(ports_list)):
        for ip in ips_list:
            port = ports_list[i]
            url = f'http://{ip}:{port}'
            try:
                response = requests.get(url, headers=headers, timeout=.1)
                print(f' {ip}:{port} : {response.headers.get("Server")}')
            except:
                pass

scan_web(ips_list, ports_list)