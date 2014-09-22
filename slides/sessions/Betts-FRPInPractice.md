![](http://some.image)
# FRP In Practice: Taking a look at Reactive[UI/Cocoa]

---

# Why?

---

> We can no longer write synchronous software
-- Bob Dylan, quoting Abraham Lincoln

^ We've seen a lot of great talks around using FRP with web software, I want to share our experience with using FRP ideas in desktop software

^ Almost everything I'm talking about applies just as well to mobile software

---

## GitHub Desktop

![50%,left,original](http://cl.ly/image/2u3E0S180k25/content#png)
![50%,right,original](http://cl.ly/image/2f2b2D0e1z2A/content#png)

^ GitHub Desktop (here's the original screenshots)

^ Started as Best Practices™ imperative applications

^ Now nearly entirely driven by signals

---

# Reactive Extensions: Async Data Flow FRP

![](http://include.aorcsik.com/wp-content/uploads/2014/05/Rx_Logo_512.png)

^ If you didn't see Evan's great talk earlier today, make sure to catch it on video, it was great

^ As he mentioned, Rx fits into the "Async Data Flow" model of FRP; our language can't give us any guarantees so we're on our own

---

## Rx Primitives

*Creating Observables*: `Observable.Return(42)`

*Transforming Observables*: `something.Select(x => x * 5)`

*Changing Contexts*: `something.ObserveOn(RxApp.MainThreadScheduler)`

![](http://include.aorcsik.com/wp-content/uploads/2014/05/Rx_Logo_512.png)

^ Rx is the Continuation Monad in a library

^ One important practical thing is the notion of a Scheduler (explain schedulers and switching contexts)

---


# ReactiveUI: Rx + Your Favorite UI Toolkit

![80%, left](http://include.aorcsik.com/wp-content/uploads/2014/05/Rx_Logo_512.png)
![100%,right](https://avatars2.githubusercontent.com/u/2327577)

^ Started around early 2010

^ Originally for Windows, now for every platform via Xamarin

---

# ReactiveCocoa: ObjC + Your Favorite UI Toolkit whose name literally ends in "Kit"

![150%,left](http://upload.wikimedia.org/wikipedia/en/4/43/Apple_Swift_Logo.png)
![100%,right](https://avatars2.githubusercontent.com/u/3422977)

^ Started in March 2012 by Josh Abernathy

^ Originally written for AppKit and Objective C, now most users are writing UIKit applications, and the in-development 3.0 version is written in Swift

---

![fit](http://cl.ly/image/393W3U0J3K2L/content#png)

^ ReactiveCocoa has really taken off in the Cocoa community, much moreso than ReactiveUI.

^ Every year during WWDC, we throw an informal conference called "RACDC", if you're in town, it's a great mini-conference

---

## ReactiveUI Primitives

**WhenAny**: Observe properties of objects

**ToProperty**: creates read-only derived properties from Observables

**Command**: an abstraction to invoke and marshal an asynchronous method

**Observable Lists**: mutable lists whose changes can be Observed

^ While RxUI does a lot of different things, four of the most interesting things it provides are these

---

## WhenAny

```cs
this.WhenAny(x => x.Sha, x => x.Value)
    .Select(sha =>
        sha == null || sha == unknownSha ?
        "(n/a)" :
        sha.Length > 7 ?
            sha.Substring(0, 7) :
            sha)
    .ToProperty(this, x => x.ShortSha, out shortSha);
```

![](https://avatars2.githubusercontent.com/u/2327577)

^ I tried as much as possible to take verbatim examples from GitHub Desktop, so they're not Pretty™

^ This demonstrates creating a Signal from an object property, transforming it, then creating a derived property.

---

## Commands

```cs
LoadUsersAndAvatars = ReactiveCommand.CreateAsyncTask(async _ => {
    var users = await LoadUsers();

    foreach(var u in users) {
        u.Avatar = await LoadAvatar(u.Id);
    }

    return users;
});

LoadUsersAndAvatars.ToProperty(this, x => x.Users, ref users);

LoadUsersAndAvatars.ThrownExceptions
    .Subscribe(ex => this.Log().WarnException("Failed to load users", ex));
```

![](https://avatars2.githubusercontent.com/u/2327577)

^ It's super common in an interface to run a background operation, ensure that operation doesn't run concurrently, then present the result on the UI. Commands are RxUI/RACs way of encapsulating this notion.

^ Commands automatically marshal their results onto the correct thread

---

# Observable Collections

```cs
public class TweetsListViewModel : ReactiveObject
{
    ReactiveList<Tweet> Tweets = new ReactiveList<Tweet>();

    IReactiveDerivedList<TweetTileViewModel> TweetTiles;
    IReactiveDerivedList<TweetTileViewModel> VisibleTiles;

    public TweetsListViewModel()
    {
        TweetTiles = Tweets.CreateDerivedCollection(
            x => new TweetTileViewModel() { Model = x },
            x => true,
            x => x.CreatedAt);

        VisibleTiles = TweetTiles.CreateDerivedCollection(
            x => x,
            x => !x.IsHidden);
    }
}
```

^ The cool thing about collections which we can observe, is that we can create projections of collections

^ The inputs to these projections themselves can be Signals, and we can update dynamically

^ This looks super cool, but right now is a bit of a Troll

---

## Elm and ReactiveUI comparisons

* Both effectively use time-varied values (i.e. Behaviors)

* Elm helps you with scheduling and ordering, Rx makes you think about it explicitly

* Elm disallows signals-of-signals, Rx lets you use them (but doesn't provide any help with it)

![](http://elm-lang.org/logo.png)

^ Today we learn that not having language support for your ideas makes them way uglier :)

---

# Some great things

![](http://citythatbreeds.com/blog/wp-content/uploads/2009/04/st_howto_f.jpg)

---

![](https://raw.githubusercontent.com/jspahrsummers/enemy-of-the-state/master/state.gif)

^ I'm not smart enough to write stateful async apps anymore

^ State in large applications is completely unmanageable - it is Easy but not Simple

^ UI state has a ton of intermediate values that are derived from inputs. Making sure that these values (aka "caches") are updated (aka "invalidated"), is Hard, especially once the concept of Race Conditions and non-derministic ordering come in

---

# A Consistent Model of Asynchrony

* Imperative code has 1030534x ways to model asynchrony (callbacks, events, promises)

* Modeling asynchronous code in tests is actually possible

^ Rx allows you to wrap imperative code in some boring mechanical code which brings it into a consistent model

---

# A *Powerful* Model of Asynchrony

* Describing complicated policies of asynchronous operations become sane to write

* Discrete UI concepts can be written **succinctly**

^ What I really want to do is have the mapping between how I think about UI in my head and how I write the code, to be really simple and as minimal as possible

^ I don't want to spew code all over a file to add a feature, I want to add it in one place, and I don't want to touch other features to add new ones.

^ Good ReactiveUI views are almost entirely written in the constructor, because the interesting bits are declaring how things are related.

---

![fit](http://cl.ly/image/003M0i1D2540/content#png)

^ This is called the "Undo Flash", it pops up whenever you do anything in GitHub for Windows and allows you to step back

^ Its logic for being dismissed is actually pretty interesting

---

## Expressing Complicated UI Intent

```cs
// Dismiss the undo flash after a certain amount of time.
// NB: The logic here is, "Show the flash for at *least* 5
// seconds. If the user does any UI action after that, *or*
// it's been a super long time, dismiss the flash"
Observable.Timer(TimeSpan.FromSeconds(5.0), RxApp.MainThreadScheduler)
    .SelectMany(_ =>
        Observable.Amb(
            anyUIAction.Take(1),
            Observable.Timer(TimeSpan.FromSeconds(20.0), RxApp.MainThreadScheduler).SelectUnit()))
    .TakeUntil(ex.DoUndo)
    .Where(x => ex.Ok.CanExecute(null))
    .Subscribe(_ => ex.Ok.Execute(null));
```

^ ![](http://www.cyberthrillerstudios.com/cyberthrillerstudios/site/transparent_spacer.gif)

---

# Time Travel Testing

^ Rx allows you to treat canned simulated time and real-time with the same code

^ Stock traders use this all of the time to run through historical stock data, then "fast-forward" to real-time.

---

```cs
[Fact]
public void CommitterDateTakesPrecedenceForRelativeTime()
{
    new TestScheduler().With(sched => {
        var c = new CommitModel(Mock.Of<IAvatarProvider>());
        sched.Start();

        c.AuthorDate = sched.Now;
        sched.Start();

        Assert.Equal("just now", c.FriendlyRelativeCommitTime);

        sched.AdvanceBy(TimeSpan.FromMinutes(5));
        c.CommitterDate = sched.Now;
        sched.AdvanceBy(TimeSpan.FromMinutes(5));
        c.UpdateCommitTime.Execute(null);
        sched.Start();

        Assert.Equal("5 minutes ago", c.FriendlyRelativeCommitTime);
    });
}
```

![](http://www.cyberthrillerstudios.com/cyberthrillerstudios/site/transparent_spacer.gif)

^ Time Travel Testing, not as good as Time Travel Debugging but still cool

---

> "I have no idea how anyone can write apps without Rx"
-- Every developer I've met who gets good at RxUI / RAC

^ Thinking in FRP is hard to learn, large imperative async apps are easy to approach but impossible to reason about

---

# Some not great things

![original](http://distilleryimage4.ak.instagram.com/715dbcde199611e497a090e2ba653da8_8.jpg)

---

## Team Education

* Most developers haven't used RxUI / RAC before, every developer we hire has to take The RAC Class™

* New developers will fall back onto writing imperative code

^ Code review is really important for new developers, it takes time for people to grok this model

---

# UI Frameworks care about Threads
#### (or really, just one thread)


^ Marshaling by-hand sucks, we shouldn't have to think about this

^ ReactiveUI originally tried to make this easy, but making it easy also made it slow because of convoying

---

![original](http://cdn.wonderfulengineering.com/wp-content/uploads/2014/04/space-wallpapers-3.jpg)
# Space and Time (leaks)

---

## Creating long chains of events is cruise control for memory leaks

^ Everything is tied to the View => leaking tiny objects can eventually tie to giant objects

^ I spent months tracking down memory leaks in GitHub for Windows, mostly around our UI Toolkit

^ Tracking down subscription leaks in huge apps sucks

---

![fit](http://cl.ly/image/2M1Z0X330c0k/content)

^ This is an old screenshot, we basically end up tracking down this stuff using rocks and sticks

---

![filtered](http://legacyproject.human.cornell.edu/files/2014/03/list-for-living.2-1xswisr.jpg)

## Virtualizing Lists are **really** sensitive to allocations

## Rx **loves** allocations

^ Really important on Mobile, the virtualizing list is a core piece

^ Creating WhenAnys and bindings are too expensive to do in a draw loop

^ Creating smooth scrolling lists is Just Hard™, this problem isn't unique to RxUI/RAC

---

## Long Call Stacks are Scary

---

![fit](http://cl.ly/image/2g210V1Z3p23/content#png)

^ This crash is in an iOS app actually, we see the bug at the top, it's a Xamarin.iOS runtime bug

---

![fit](http://cl.ly/image/310p3D1v400V/content#png)

^ If we stripped any line containing 'System.Reactive', we'd get a way better idea of this stack

---

![fit](http://cl.ly/image/27153f1g0A0R/content#png)

^ Aaaaaand here we go, we've found main()

---

# Tooling can Help Us Out

^ Most of these caveats can be helped quite a bit via debugging tools

^ Many don't exist, but we're trying to hack on a few

---

# Logging and tracing

* Setting up a good logging framework is *critical*

* Log Signals that end in an error

* Signals are natively dual-point logging (i.e. they represent a Span)

---

![fit](http://i.msdn.microsoft.com/dynimg/IC572176.png)

^ This is Concurrency Visualizer, basically the best part of Visual Studio

^ Signals have length just like the blocks we see above, but they're difficult to get into this particular UI

---

![fit](http://cl.ly/image/271C3h2Z293b/content#png)

^ RAC has DTrace, but it has even less of a UI. The information is there though!

---

![fit](https://camo.githubusercontent.com/5a6cd710205901914de819f4cc7b8c2124433647/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f3633343036332f323139303631302f61653663303530382d393832642d313165332d393062332d6262623366666263323331372e706e67#jpg)

^ One of the developers on the Desktop team, Markus Olsson, is working on a tool to visualize Signals explicitly

---

![fit](https://cloud.githubusercontent.com/assets/634063/4266126/a73741d6-3c73-11e4-8cb9-ef023f69b4f6.png)

^ Having this kind of app-specific information available is the key to bring Signals to the rest of the world.

---

> Thanks!
-- @paulcbetts
