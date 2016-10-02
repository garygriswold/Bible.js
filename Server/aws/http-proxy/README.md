This project is a web proxy server that was built using claudia.js, and is deployed on Amazon API Gateway and Amazon Lambda.

API Gateway is typically used to develop API's that send and receive JSON, but claudia.js provides a simply way to use this
for web.

If this codes is modified, the modification can be deployed using the command: claudia update

The proxy server is called as follows:

https://mrf2p6k5ud.execute-api.us-west-2.amazonaws.com/latest/web?url={full url and path including http}



NOTE:::::::::: Gary Griswold Oct 1, 2016

This server has not been finished and put into production.  It kind of works, but not well enough to use.
1. It occasionally returns JSON messages of Internal Server Error, or Forbidden.  It is not clear why this occurs, or why it is JSON message. Consider putting a try catch around the entire api call to see if that corrects the problem.

2. The rewriting of relative URL's is not working correctly.  It appears that the hostname and pathname of the original request are getting to the pageRewriter module.

3. Some gets, especially True Type Font gets are being rejected because they are http to a different server, when the original request to the proxy was https.  I think it would be OK to make these requests outside the proxy.  So, the pageRewriter could be changed so that requests to a different server are not rewritten.

4. Maybe rewriting the page inside the server is not the best approach.  Maybe the correct solution is to add the rewriting logic to the InAppBrowser.  This would require modifying the plugin in both Apple and Android.