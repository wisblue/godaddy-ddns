package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net"
	"strings"
)

// func main() {
// 	fmt.Println(getPubIP())
// }

func getPubIPTest() (string, error) {

	type GetIPBody struct {
		IP string `json:"ip"`
	}

	var ipbody GetIPBody
	var response *http.Response

	

	client := &http.Client{}
	req, _ := http.NewRequest("GET", "https://ip.run", nil)
	req.Header.Set("User-Agent", ": curl/7.68.0")


	response, err := client.Do(req) //http.Get("https://ip.run")
	if err == nil {
		defer response.Body.Close()
		bodyBytes, err := ioutil.ReadAll(response.Body)
		if err != nil {
			// fmt.Println(err.Error())
			return "", err
		}
		resp_str := string(bodyBytes)
		for _, word := range strings.Split(resp_str, " ") {
			//fmt.Println(word)
			// try to parse the word as an IP address
			ip := net.ParseIP(word)
			// if the word is a valid IP address
			if ip != nil {
				// print the IP address
				//ipbody.IP = ip.String()
				return ip.String(), nil
			}
		}

	} 

	response, err = http.Get("https://api.ipify.org/?format=json")
	if err != nil {
		response, err = http.Get("https://ipinfo.io/json")
		if err != nil {
			return "", nil
		}
	}

	defer response.Body.Close()
	bodyBytes, err := ioutil.ReadAll(response.Body)
	if err != nil {
		// fmt.Println(err.Error())
		return "", err
	}

	err = json.Unmarshal(bodyBytes, &ipbody)
	if err != nil {
		// fmt.Println(err.Error())
		return "", err
	}

	return ipbody.IP, nil

}
