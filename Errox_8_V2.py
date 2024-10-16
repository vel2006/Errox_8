import multiprocessing
import multiprocessing.process
import threading
import socket
import re
import os

#Declaring strings for not having to remember each of them
errorHead = "[!] "
infoHead = "[*] "
miscHead = "[#] "


#Declaring variables
targetIP = ""
threadLimit = 0
processLimit = 0
portsPerThread = 0
selectedPorts = []
ipaddressPattern = re.compile(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', re.IGNORECASE)

#Method for scanning ports as a thread
def ScanPort(ports:list, targetIP:str):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    for port in ports:
        if not sock.connect_ex((targetIP, port)):
            print(f"{infoHead}Port: {port} is open!")

#Method for port scanning on several ports / threads as a process
def ScanPorts(amountOfThreads:int, portsTuple:list, target:str):
    threads = []
    amountPerThread = int(len(portsTuple) / amountOfThreads)
    lastPortInterval = 0
    for i in range(amountOfThreads):
        portsUsed = lastPortInterval + amountPerThread
        thread = threading.Thread(target=ScanPort, args=(portsTuple[lastPortInterval:portsUsed], target), )
        lastPortInterval = portsUsed
        thread.start()
        threads.append(thread)
    for thread in threads:
        try:
            thread.join()
        except:
            threads.remove(thread)

if __name__ == '__main__':
    print(" _____ ____  ____   _____  __    ___   __     ______")
    print("| ____|  _ \\|  _ \\ / _ \\ \\/ /   ( _ )  \\ \\   / /___ \\")
    print("|  _| | |_) | |_) | | | \  /    / _ \   \\ \\ / /  __) |")
    print("| |___|  _ <|  _ <| |_| /  \   | (_) |   \\ V /  / __/")
    print("|_____|_| \\_\\_| \\_\\\\___/_/\\_\\___\\___/     \\_/  |_____|")
    print("                           |_____|")
    targetIP = input(f"{miscHead}Input the IP address you wish to scann.\n>")
    if ipaddressPattern.findall(targetIP):
        pass
    else:
        print(f"{errorHead}Error: Input IP address is not an IP address, ending script...")
        exit()
    smlScanPorts = (7, 9, 13, 21, 22, 23, 25, 26, 37, 53, 79, 80, 81, 88, 106, 110, 111, 113, 119, 135, 139, 143, 144, 179, 199, 389, 427, 443, 444, 445, 465, 513, 514, 515, 543, 544, 548, 554, 587, 631, 646, 873, 990, 993, 995, 1025, 1026, 1027, 1028, 1029, 1110, 1433, 1720, 1723, 1755, 1900, 2000, 2001, 2049, 2121, 2717, 3000, 3128, 3306, 3389, 3986, 4899, 5000, 5009, 5051, 5060, 5101, 5109, 5357, 5432, 5631, 5666, 5800, 5900, 6000, 6001, 6646, 7070, 8000, 8008, 8009, 8080, 8081, 8443, 8888, 9100, 9999, 10000, 32768, 49152, 49153, 49154, 49155, 49156, 49157)
    midScanPorts = (1, 3, 4, 6, 7, 9, 13, 17, 19, 20, 21, 22, 23, 24, 25, 26, 30, 32, 33, 37, 42, 43, 53, 70, 79, 80, 81, 82, 83, 84, 85, 88, 89, 90, 99, 100, 106, 109, 110, 111, 113, 119, 125, 135, 139, 143, 144, 146, 161, 163, 179, 199, 211, 212, 222, 254, 255, 256, 259, 264, 280, 301, 306, 311, 340, 366, 389, 406, 407, 416, 417, 425, 427, 443, 444, 445, 458, 464, 465, 481, 497, 500, 512, 513, 514, 515, 524, 541, 543, 544, 545, 548, 554, 555, 563, 587, 593, 616, 617, 625, 631, 636, 646, 648, 666, 667, 668, 683, 687, 691, 700, 705, 711, 714, 720, 722, 726, 749, 765, 777, 783, 787, 800, 801, 808, 843, 873, 873, 880, 888, 898, 900, 901, 902, 903, 911, 912, 981, 987, 990, 992, 993, 995, 999, 1000)
    match input(f"{miscHead}What amount of ports do you wish you scan, \'small\' or \'large\'\n>").lower():
        case "small":
            selectedPorts = smlScanPorts
        case "large":
            selectedPorts = midScanPorts
        case default:
            print(f"{errorHead}Error: Invalid port amount, setting to default small...")
            selectedPorts = smlScanPorts
    try:
        processLimit = int(input(f"{miscHead}Input the number of processes you want.\n>"))
    except:
        print(f"{errorHead}Error: Invalid amount of process, setting to half of system CPU core count...")
        processLimit = int(os.cpu_count() / 2)
    try:
        threadLimit = int(input(f"{miscHead}Input the number of threads you want for each process.\n>"))
    except:
        print(f"{errorHead}Error: Invalid amount of threads, setting to defauly ten...")
        threadLimit = 10
    portsPerThread = len(selectedPorts) / processLimit
    processes = []
    amountPerThread = int(len(selectedPorts) / processLimit)
    lastProcessInterval = 0
    for process in range(processLimit):
        try:
            portsUsed = lastProcessInterval + amountPerThread
            newProcess = multiprocessing.Process(target=ScanPorts, args=(threadLimit, selectedPorts[lastProcessInterval:portsUsed], targetIP))
            lastProcessInterval = portsUsed
            newProcess.start()
            processes.append(newProcess)
        except:
            continue
    for process in processes:
        try:
            process.join()
            processes.remove(process)
        except:
            processes.remove(process)
