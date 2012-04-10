About flensed
The What

flensed is a collection of completely free and open-source UI tools and widgets which fundamentally are based on the incredible, often untapped, enabling functionalities provided by the Flash Player plugin in modern browsers.
The Flash Player plugin is installed in 99% of all web browsers.

The foundational flensed project is CheckPlayer, which extends the SWFObject Library External Link in some useful ways that make it easier to attach SWF's to a web page at any point in the DOM's lifespan. The functionality of CheckPlayer allows all other flensed projects to easily leverage SWF's in ways that web authors before have scarcely been able to achieve.

The idea is to leverage SWF support in a browser (which Adobe claims is now 99% worldwide External Link) to solve some difficult problems that website authors commonly struggle with when trying to push their sites to the limits of Web 2.0, 3.0, whatever. These projects are based on the premise that SWF's can be added to a webpage dynamically and unobtrusively, combined and controlled with intelligent, integrated Javascript code and some supportive HTML markup, to address those problems.
The Where

If you're wondering if flensed has any real world potential...

    Pointserve, Inc. External Link (Austin, TX)
    Pointserve uses some of the flensed projects (CheckPlayer and flXHR) to solve third-party application integration and UX usability issues with some of their clients.
    Read More


The How

All flensed projects use (and come bundled with) a set of utility functions called the flensedCore. Some projects dynamically add additional functions to this set. This handful of small utility functions is similar to a small subset of the functionality you might find in existing Javascript frameworks, including 'getObjectById', 'bindEvent', 'parseXMLString', etc. All Core functions are public and available to web authors to use as needed.
flensed offers real solutions now, using almost universal existing technology.

flensed projects come in two flavors. Some of the projects are primarily focused on letting SWF's be invisible to the viewer, but nonetheless do some heavy lifting in the background. For instance, flXHR addresses the need for a clean, efficient, and API-compatible way to make cross-domain calls from client to server. flACHEY aims to provide a unique way of slashing to a fraction the amount of client download needed for the common Javascript frameworks which are already deployed to such a wide audience. Why should a user have to visit 100 different websites and download Dojo or jQuery 100 times because the browser isn't smart enough to allow common code sharing between the sites? flACHEY will make that a reality. So in an ironic nod to the many diehard Javascript'ers who would normally reject a solution based on Flash, flACHEY provides an easy way for web authors to make their site's Javascript resources shareable which ultimately improves download times and user experience for all visitors.

The other flavor of flensed projects focus more on the visible presentation of interactive webpage elements. Essentially, strategically placed SWF's will masquerade as intelligent drop-in replacements for common presentation elements, such as images, menus, or form elements. Certainly all these things can be done now, but authors and frameworks have to jump through endless hoops to keep the presentation consistent for all viewers.

Flash Player plugins in all modern browsers create an almost entirely consistent presentation canvas, and sometimes can even be done in smaller download size than their Javascript/CSS counterparts. Many have used SWF's on web pages for all these items before, and many others have rejected these options because of the lack of semantics, search-engine friendliness, and accessibility issues that a large section of current SWF implementations suffer from. flensed re-thinks these issues from the ground up, and uses the minimal amount of SWF to achieve the consistency that users deserve, while still giving web authors the strongest and most forward-thinking presentation layer solutions possible.
The Why
Strategically placed SWF's masquerade as intelligent drop-in replacements for common presentation elements.

In some cases, these projects seek to offer an alternative to existing approaches and workarounds (most of which are written by those who avidly adhere only to creative/hackish Javascript/CSS as the silver bullet). Because they accomplish so many amazing things with magical Javascript artistry, they probably scoff at the idea that sometimes a browser plugin may be of assistance. I respect that view and won't try to convince you otherwise. But I respectfully disagree, and I present flensed in contrast to that mindset. I submit to the general web author audience that despite Flash's perhaps sometimes dubious reputation, there are plenty of advantages which may have been overlooked in the rush to escalate Javascript's ubiquity, as if the world of plugins is now somehow the second-class citizen in the web community.

In other cases, the solutions provided by flensed projects yield a novel, unique solution which has yet to be properly addressed by the web community. In either case, there is a segement of the web author community who is mainly pushing on the browser vendors to find unity on these concerns, but they have been waiting a very long time already, and I believe will continue to have to wait for the painful machinations of browser evolution to churn out a "solution".

While the utopian view of this being "the right solution" is very idealistic and attractive, the practicality is that there are many websites right now which need to address these issues and don't have the luxury of that waiting game. flensed offers real solutions now, and it relies on existing technology that is almost universally deployed among the common web audience environments.

I suggest that right now there is no other highly consistent cross-browser solution out there which comes nearly as close to achieving a 99% spread of the worldwide web audience. On that point alone, I believe that the flensed projects have a lot to offer to the website author/programmer, at least for deeper consideration. What I am suggesting is that maybe it wouldn't hurt if we did some re-thinking on some of these topics, which is what flensed is doing.
The Who

No, not the band External Link. flensed is an open-source effort put out by Getify Solutions, Inc., a small web design and hosting company in Austin, TX. Kyle Simpson is the primary author, and he does this stuff in his free time. 
