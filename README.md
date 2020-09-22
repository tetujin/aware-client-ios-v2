![](http://www.yuukinishiyama.com/wp-content/uploads/2019/03/aware-client-v2-eyecatch-01.png)

## AWARE Framework iOS Client (Version 2)
[AWARE](http://awareframework.com) is an iOS and Android framework dedicated to instrument, infer, log and share mobile context information,
for application developers, researchers and smartphone users. AWARE captures hardware-, software-, and human-based data. It encapsulates analysis, machine learning and simplifies conducting user studies in naturalistic and laboratory settings. 

![User Studies](http://www.awareframework.com/wp-content/uploads/2014/05/aware_overview1.png)

The platform is scalable with plugins and can be integrated with other platforms using JSON, MQTT or MySQL.

![Arquitecture](http://www.awareframework.com/wp-content/uploads/2015/12/aware-architecture.png)

You can now refer to AWARE's functions inside your app.

### Individuals: Record your own data
No programming skills are required. The mobile application allows you to enable or disable sensors and plugins. The data is saved locally on your mobile phone. Privacy is enforced by design, so AWARE does not log personal information, such as phone numbers or contacts information. You can additionally install plugins that will further enhance the capabilities of your device, straight from the client.

### Scientists: Run studies
Running a mobile related study has never been easier. Install AWARE on the participants phone, select the data you want to collect and that is it. If you use the AWARE dashboard, you can request your participants’ data, check their participation and remotely trigger mobile ESM (Experience Sampling Method) questionnaires, anytime and anywhere from the convenience of your Internet browser. The framework does not record the data you need? Check our tutorials to learn how to create your own plugins, or just contact us to help you with your study! Our research group is always willing to collaborate.

### Developers: Make your apps smarter
Nothing is more stressful than to interrupt a mobile phone user at the most unfortunate moments. AWARE provides application developers with user’s context using AWARE’s API. AWARE is available as an Android library. User’s current context is shared at the operating system level, thus empowering richer context-aware applications for the end-users.

## How To Use
* [Development | UI](http://www.awareframework.com/introduction-of-aware-ios-client/)
* [Development | Sensors & Plugins](https://github.com/tetujin/AWAREFramework-iOS)
* [Distribution Methods](http://www.awareframework.com/distributing-methods-of-aware-ios/)
* [ESM | URL](http://www.awareframework.com/schedule-esms-for-aware-ios-client/)
* [ESM | Calendar Scheduler](https://github.com/tetujin/AWAREFramework-iOS/tree/master/AWAREFramework/Classes/Plugins/CalendarESMScheduler)
* [ESM | Hard Coding](https://github.com/tetujin/AWAREFramework-iOS)

## Author
AWARE Client iOS (Version 2) is developed by [Yuuki Nishiyama](http://www.yuukinishiyama.com/) (Community Imaging Group, University of Oulu). Also, [AWARE framework](http://www.awareframework.com/) and [AWARE Framework client](https://github.com/denzilferreira/aware-client) (for Android) were created by [Denzil Ferreira](http://www.denzilferreira.com/) (Community Imaging Group, University of Oulu) and his group originally.

## Related links
* [AWARE Framework Official Home Page](http://www.awareframewrok.com)
* [aware-client-ios-v2 on AppStore](https://itunes.apple.com/jp/app/aware-client-v2/id1455986181)
* [aware-library-ios](https://github.com/tetujin/AWAREFramework-iOS)
* [aware-client-ios-v1](https://github.com/tetujin/aware-client-ios)
* [aware-client-Android](https://github.com/denzilferreira/aware-client)


## Citation
Please cite the following paper(s) in your publications if it helps your research. 

```
@InProceedings{aware_ios,
    author={Nishiyama, Yuuki and Ferreira, Denzil and Eigen, Yusaku and Sasaki, Wataru and Okoshi, Tadashi and Nakazawa, Jin and Dey, Anind K. and Sezaki, Kaoru},
    title={IOS Crowd--Sensing Won't Hurt a Bit!: AWARE Framework and Sustainable Study Guideline for iOS Platform},
    booktitle={Distributed, Ambient and Pervasive Interactions},
    year={2020},
    pages={223--243},
    isbn={978-3-030-50344-4},
    doi={10.1007/978-3-030-50344-4_17},
}

@inproceedings{aware_ios_in_the_wild,
    author = {Nishiyama, Yuuki and Ferreira, Denzil and Sasaki, Wataru and Okoshi, Tadashi and Nakazawa, Jin and Dey, Anind K. and Sezaki, Kaoru},
    title = {Using IOS for Inconspicuous Data Collection: A Real-World Assessment},
    year = {2020},
    doi = {10.1145/3410530.3414369},
    booktitle = {Adjunct Proceedings of the 2020 ACM International Joint Conference on Pervasive and Ubiquitous Computing and Proceedings of the 2020 ACM International Symposium on Wearable Computers},
    pages = {261–266},
    numpages = {6},
    series = {UbiComp-ISWC '20}
}
```

## License
Copyright (c) 2019 AWARE Mobile Context Instrumentation Middleware/Framework for iOS (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

