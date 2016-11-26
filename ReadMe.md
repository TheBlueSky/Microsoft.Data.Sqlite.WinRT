# Microsoft.Data.Sqlite for WinRT #

## What is it? ##

This repository contains ASP.NET implementation of [`Microsoft.Data.Sqlite`](https://github.com/aspnet/Microsoft.Data.Sqlite) modified to support WinRT for Windows 8.1 and Windows Phone 8.1.

Because `Microsoft.Data.Sqlite` rely on `System.Data.Common`, which does not exist in WinRT for Windows 8.1 and Windows Phone 8.1, this repository also contains 
.NET Core implementation of [`System.Data.Common`](https://github.com/dotnet/corefx) modified to support WinRT for Windows 8.1 and Windows Phone 8.1.

The result is `Microsoft.Data.Sqlite` and `System.Data.Common` libraries that achieve 100% feature parity with the ones from original repositories:

* `Microsoft.Data.Sqlite`: commit [58195cb10236f22c14a6cef2e7e80ccf1b0e2462](https://github.com/aspnet/Microsoft.Data.Sqlite/tree/58195cb10236f22c14a6cef2e7e80ccf1b0e2462).
* `System.Data.Common`: commit [714c3d65b723a267c30f5b820fb651fe6ea30cac](https://github.com/dotnet/corefx/tree/714c3d65b723a267c30f5b820fb651fe6ea30cac).

Still, see "How?" and "Pitfalls and Known Issues" sections to see if there is any limitation and unsupported feature.

## Why it is needed? ##

It came out of a personal need. I was developing a Windows 8.1 Universal app and wanted some sort of database-like storage. Instead of reinventing the wheel, I looked around for proven-to-be-working solutions.

Most of the roads eventually let to [SQLite](https://www.sqlite.org/download.html) and its WinRT support for Windows 8.1 and Windows Phone 8.1. However, neither Microsoft nor SQLite.org has a .NET wrapper for the native APIs for my targeted platforms.

The natural fallback is 3rd party and community libraries. The ones I came across have one or more of the following:

1. Missing some features that I wanted.
2. Cannot be used in a portable library that targets WinRT.
3. Require some learning curve due to the way their APIs are written.
4. Not updated for years; hence their compatibility with the latest SQLite library is unknown.

Hence, "plan C" was to port the library that I have some familiarity with, which is `Microsoft.Data.Sqlite`, and its dependencies.

## How it was done? ##

It was mostly manual work:

1. Created a Visual Studio solution with 2 Portable Class Library projects, targeting Windows 8.1 and Windows Phone 8.1. The projects are named `Microsoft.Data.Sqlite` and `System.Data.Common`; where `Microsoft.Data.Sqlite` project references `System.Data.Common`.
2. Copied the files from .Net Core [`System.Data.Common`](https://github.com/dotnet/corefx) repository, and its referenced files, and placed them in `System.Data.Common` projects; where a folder represents a `namespace`.
3. Copied the files from ASP.NET [`Microsoft.Data.Sqlite`](https://github.com/aspnet/Microsoft.Data.Sqlite) repository and placed them in `Microsoft.Data.Sqlite` projects; where a folder represents a `namespace`.
4. Removed `winsqlite3` item from `dllNames` array in [`NativeMethodsImpl.tt`](src/Microsoft.Data.Sqlite/Interop/NativeMethodsImpl.tt) file. Note: Although `winsqlite3.dll` is not available and not used in WinRT for Windows 8.1 and Windows Phone 8.1 apps, Windows App Certification Kit generates ["API not supported errors"](https://github.com/TheBlueSky/Microsoft.Data.Sqlite.WinRT/issues/1) that may prevent approving the app.
5. Compiled the code and see what the compiler is complaining about.
6. Replace the code that is not supported in WinRT for Windows 8.1 and Windows Phone 8.1 with the equivalent alternative; e.g, `Debug.Fail("Message")` was replaced by `Debug.Assert(false, "Message")`.
7. Removed the code that is not supported at all in WinRT for Windows 8.1 and Windows Phone 8.1; e.g., `Environment.GetEnvironmentVariable("EnvVariable")` (you cannot read or write Environment variables in WinRT).
8. Compiled again. If the compiler is still complaining, go to #5, otherwise got to #8.
9. Celebrate.

## How to get it? ##

Execute the following command in Package Manager Console:

`Install-Package Microsoft.Data.Sqlite.WinRT`

Or search for `Microsoft.Data.Sqlite.WinRT` in NuGet Package Manager.

## Pitfalls and Known Issues ##

None of these pitfalls and known issues are known to cause this library to "misbehave":

1. As stated in "How it was done?" section, this is a manual work and similar work needs to be done to maintain the library.
2. There are several places in the code where Preprocessor Directives, such as `#if NET451` and `#if !NET451`, are used. Because `NET451` is not defined, the code which is not for `NET451` is the one that is eventually compiled. I have not reviewed or tested all these Directives to see their behaviour in WinRT for Windows 8.1 and Windows Phone 8.1.
3. ASP.NET team uses some version of `ResXFileCodeGenerator` that generates methods with parameters from `*.resx` files. I don not have this version and do not know how to get it (if someone knows, I appreciate a help). Hence, every time the resources are regenerated, I have to revert the generated file to the pre-generated file I took from the original repository, and if anything is added, I will add it manually.
4. Because the code that uses `winsqlite3.dll` was removed (see "How it was done?" section), calling `SqliteEngine.UseWinSqlite3()` will fall back to using `sqlite3.dll` that is shipped with the app. This should not be an issue. I am unaware of any case where someone might need to use `winsqlite3.dll` with a library that targets WinRT for Windows 8.1 and Windows Phone 8.1, or if this will even work.

## What about the future? ##

Nothing fancy and there are no big plans awaits this work; yet, it is not abandoned.

Here are couple of ideas that might come in some point in the future:

* Look at the original repositories for any update and reflect the changes on this repository.

* Add the test projects from the original repositories.

* Keep maintaining the version number with the original libraries; Major and Minor, not Build and Revision.

* Merge the changes with the original repositories. `System.Data.Common` support [.NETStandard 1.2](https://docs.microsoft.com/en-us/dotnet/articles/standard/library), which means supporting WinRT for Windows 8.1 and Windows Phone 8.1. But, `Microsoft.Data.Sqlite` only supports .NETStandard 1.3 because it reads Environment Variables. There are 2 things need to happen before the merge, (1) finding a way to get Environment Variables in .NETStandard 1.2, and (2) finishing MSBuild changes that allow using .NETStandard libraries in none-.Net Core projects.

* Separate `Microsoft.Data.Sqlite` and `System.Data.Common` into different NuGet packages. I will do this only if (1) `System.Data.Common` proven to be useful by itself, and (2) the previous point is not done.

## License ##

Both the codes maintain their original license:

* `Microsoft.Data.Sqlite`: Apache License, Version 2.0
* `System.Data.Common`: The MIT License (MIT)

I have not changed the original code in any way that modifies its function; hence, all the credits and the copyrights go wherever they go in the original repositories.

## Thanks ##

My thanks go to the teams behind .NET Core and ASP.NET, the people behind open-sourcing .NET and related libraries, and the people who contributed to the original repositories. Without there work, this repository would not be possible; at least, not without considerable effort.

## Final words ##

It is a success story. My success criteria is that I was able to use this work in my project.

I put this work here and on NuGet.org because it was useful for me. I hope that someone other than myself will find it useful for them.