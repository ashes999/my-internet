# Work in Progress
**Best Case:** It's just a different URL in your browser. Make it happen, G.

Core components:
  - **Search:** How do I find stuff from my local version? Is it a web app?
  - **Management:** Give me an interface to add sites and discover domains, etc.
  - **Indexing:** Gotta reach out to the real world and fetch pages, etc. (plus management)

From MIQ: see the beauty, problem solving, fast, result-oriented

# BRAINSTORMING

- Web apps are hard. They would be awesome, but they're seriously hard to setup/deploy.
- Flat files (eg. HTML) are not easily searchable. A database is a must.
- Background fetching/processing requires some serious infrastructure, eg. web app
- Static HTML (and images, etc.) from a lightweight, stand-alone web server can work, iff I can do search/bg-processing easily.
- Stand-alone C# application with background web processing?
- Dude. YOUR BROWSER CAN SERVE STATIC CONTENT. Duh!
- **Because of search, we will need a web server, and a DB.** there's no way around it.
- If we must have web, forget C#. Manage everything via webpages and stuff.

# Possible Stack #
* Use web stuff for DB + search; redirect to static content as required (eg. absolute URLs)
- Ruby as the language. Can I get away with a single Ruby script?
  - SQLite back-end (sql.rb)
  - Thin + Rack to serve static content (server.rb)
  - Search (???)
  - Back-end crawler (???)


# Conclusions
- It has to be drop-dead easy to use. Really, there can't be difficulty in this.
- It has to be drop-dead simple to manage. Everything should be sensible and just work.
- Make URLs as easy as possible. Eg. http://localhost:8080/stackoverflow.com/normal-url-here
- For simplest management, the bg service runs when the UI is open, and closes when it closes. Simple.
