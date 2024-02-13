To use hoverfly to capture the monolith's orders website traffic, first we need to deploy ticket monster (at this point, we've deployed it into Kubernetes/OpenShift with UI and backends split out. From our browser if we navigate to the UI, we can then set up a proxy (hoverlfy) to capture traffic and build tests around that.

startup hoverfly in capture mode:

> hoverctl start
> hoverctl mode capture

Let's capture only the requests made to the rest endpoints

> hoverctl destination "rest"

Now configure your browser to proxy to localhost:8500

Note: you can follow the hoverfly logs to make sure things are getting captured:

> hoverctl logs --follow

Now go to your browser and start exercising all of the functions of the ordering process. 


> hoverctl export simulation.json


