# 📱 Tinkoff ChatApp [![CI](https://github.com/TFS-iOS/chat-app-taymasoff/actions/workflows/github.yml/badge.svg)](https://github.com/TFS-iOS/chat-app-taymasoff/actions/workflows/github.yml)

<a href="https://youtu.be/emx09hylwFw"><img src="https://i.imgur.com/iFO85RA.gif" height="350"/></a><br>
<a href="https://youtu.be/emx09hylwFw">Watch Full Demo</a>

## 🎓 Description

Проект, разрабатываемый в рамках учебного курса iOS-Developer Tinkoff-Fintech 2021

## 💻 Technologies Used
SWIFT, MVVM, SnapKit, CoreData, Firebase/Firestore, Fastlane, Github Actions

## ⏳ Development Process

<details> 
  <summary>Week #1</summary>

**Задача:** 
> Создать проект, настроить git и засетапить gitignore файл. Затем, залогировать события жизненного цикла приложения с возможностью включить/отключить логи при компиляции.

**Решение:**
> Написал простой логер, который выводит принты с названием вызываемой функции с помощью #function и файла, откуда проброшен вызов с помощью #file. Контроль вывода осуществляется с помощью директивы препроцессора #if DEBUG.

<details> 
  <summary>Превью</summary>

  ![image](https://user-images.githubusercontent.com/29929897/134303300-2df47427-7d40-4832-8adc-4a362770ae6f.png)
</details>
</details> 

<details> 
  <summary>Week #2</summary>

**Задача:**
> Написать модуль профиля, используя следующий [дизайн](https://www.figma.com/file/9XGcex1jtnYrrZJPScET2z/Homework).

**Решение:**
> Пришло время выбирать архитектуру UI-слоя. Мой выбор пал на MVVM, так как я давно хотел испытать реактивный подход с байндингами. К сожалению, сторонние фреймворки в приложении использовать запрещено правилами курса, поэтому испытать всю мощь связки MVVM + rxSwift'а в этом проекте у меня не получилось. Я решил воспользоваться популярным решением и создать вспомогательный компонент-обертку под названием [Dynamic](https://github.com/TFS-iOS/chat-app-taymasoff/blob/master/ChatApp/ChatApp/Core/Common/Dynamic/Dynamic.swift). Он играет некую роль обсервера и пробрасывает колбеки через метод bind при каждом изменении value.  
Раньше при верстке экранов я всегда использовал сториборды, на этот раз я решил научиться описывать все кодом.   
Благо, организаторы разрешили использовать SnapKit и описывать констрейнты было довольно-таки просто. Верстка кодом мне очень понравилась - она предоставляет больше ясности и контроля.  
Профиль экрана нужно было сделать модальным, но в то же время нужно было поддерживать iOS 12. Что создает трудности, потому-что c iOS 13 модалка дисмисается свайпом, а в iOS 12 она занимает целый экран и закрыть ее без кнопки невозможно. Кнопка выглядит лишней на новых устройствах, поэтому я решил написать кастомную логику, при которой, на прозрачном вью-контролере с заблуренным фоном плавно выезжает вьюшка, занимающая 2/3 части экрана. Тут же сразу добавил обсервер клавиатуры, чтобы клавиатура никогда не закрывала поля ввода. Вьюшка смещается наверх со скоростью появления клавиатуры. Получилось неплохо. Превью есть в пул реквесте: [Pull Request (UI)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/1)
</details>

<details> 
  <summary>Week #3</summary>

**Задача:**
> Написать следующие 2 экрана приложения: экран переписок и диалога. Организовать переходы между ними. [Дизайн](https://www.figma.com/file/9XGcex1jtnYrrZJPScET2z/Homework).

**Решение:**
> Сложностей в написании экранов не было. Переходы я делегировал роутеру. Роутер я решил сделать один, так-как в дизайне довольно ограниченный флоу. Конечно, в будущем добавилось больше экранов и в один момент я пожалел, что не сделал координаторы.  
Превью есть в пул реквесте: [Pull Request (Navigation)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/2)
</details>

<details> 
  <summary>Week #4</summary>

**Задача:**
> Написать модуль выбора тем в 2 вариантах: с использованием ObjectiveC с ручным подсчетом ссылок (MRC) и на свифте с ARC. 

**Решение:**
> Наверное, это был первый серьезный челендж. Я раньше никогда не писал на objective-c. Пришлось читать очень много статей, не только про Memory Managment, но и про базовый синтаксис ObjC. Модуль на ObjectiveC я написал как один MVC модуль, максимально просто с 3 захаркожеными темами. Свифт модуль я сделал максимально презентабельным, представляя, что он все-таки будет основным в приложении. Приложение предоставляет выбор предпочитаемого метода с помощью ActionSheet. Было сложно, но вроде-бы все работает.  
Превью есть в пул реквесте: [Pull Request (MemoryManagement)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/3)
</details>

<details> 
  <summary>Week #5</summary>

**Задача:**
> Организовать сохранение и чтение состояния экранов профиля и тем с использованием файлового менеджера. Методы должны работать асинхронно с помощью GCD и Operations. Так же должна быть возможность отката до последнего состояния (Undo). (2 варианта).

**Решение:**
> Начал я "снизу" написал FileManager, AsyncFileManager, затем PersistenceManager. PersistenceManager предлагал сохранять в UserDefaults или FileManager'е в зависимости от выбранного enum'а. После дискуссии с ментором, мы пришли к выводу, что это было не лучшим решением и я разделил PersistenceManager на GCDFileManager и OperationsFileManager под единым протоколом AsyncFileManager.  
Реализацию Undo я решил сделать с помощью [DynamicPreservable](https://github.com/TFS-iOS/chat-app-taymasoff/blob/master/ChatApp/ChatApp/Core/Common/Dynamic/DynamicPreservable.swift). Он сохраняет не только текущее состояние переменной (value), но и последнее состояние (preservedValue). У него есть 3 основных метода: preserve() - сохранить текущее состояние, restore() - восстановить сохраненное состояние и bindUpdates, который кидает колбеки при любом изменении value от preservedValue.  
Превью есть в пул реквесте: [Pull Request (Multithreading)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/4)
</details>

<details> 
  <summary>Week #6</summary>

**Задача:**
> Подключить CocoaPods, добавить SwiftLint с набором правил и Firebase/Firestore, который обновляет список каналов и диалогов через веб-сокет. 

**Решение:**
> Так как CocoaPods уже был установлен, мне оставалось только добавить SwiftLint и Firestore. Линтер выдал около 100 ворнингов, но, хотя бы, не было ошибок - чему я был рад. Фикс ворнингов не занял много времени.  
Для работы с Firestore я написал набор протоколов CloudStoreProtocol. У него есть подписка/отписка на обновления и методы сохранения/удаления записей. Вью-модель на данном этапе была довольно сильно забита вызовами методов менеджера Firestore и файлового менеджера. Поэтому я вынес эти обязанности в реализацию паттерна Repository. Вью-модель теперь лишь передает команды репозиторию и получает готовое состояние.  
Превью есть в пул реквесте: [Pull Request (Firebase)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/5)
</details>

<details> 
  <summary>Week #7</summary>

**Задача:**
> Сохранять состояния экранов переписки и диалогов в модель CoreData.

**Решение:**
> После Realm'а, CoreData показалось мне чрезмерно занудной - ее не так легко настроить и понять с первого раза. Плюс есть подводные камни, о которых ничего не говорится в руководствах по настройке. Мне пришлось разделять модели на 2 сущности: NSManagedObject и DomainModel и настраивать конвертацию между ними - что было, наверное самой сложной задачей тут. Я написал CDContextProvider (который все называют CoreDataStack). CoreDataManager, который обнесен протоколами CoreDataOperatable и CDWorker, который является единицей работы и отвечает за то, чтобы все процессы в одном юните операций проходили в нужном потоке и контексте.  
Чтобы не перезаписывать БД каждый раз, когда приходит апдейт с firestore, я подписался на обновления документа, который сохраняет в структуру UpdateLog 3 массива: addedObjects, updatedObjects и removedObjects. Затем, updateCoreData метод производит необходимые обновления CoreData, в зависимости от поступивших изменений:
```
 func updateCoreData(with updateLog: CSModelUpdateLog<Conversation>?) {
        guard let updateLog = updateLog else { return }
        
        if updateLog.addedCount != 0 {
            bgWorker.coreDataManager.insert(updateLog.addedObjects) { _ in }
        }
        if updateLog.updatedCount != 0 {
            bgWorker.coreDataManager.update(updateLog.updatedObjects) { _ in }
        }
        if updateLog.removedCount != 0 {
            for object in updateLog.removedObjects {
                bgWorker.coreDataManager.removeEntity(ofObject: object) { _ in }
            }
        }
        bgWorker.saveIfNeeded { _ in }
    }
```   
> Превью есть в пул реквесте: [Pull Request (CoreData)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/7)
</details>

<details> 
  <summary>Week #8</summary>

**Задача:**
> Обновление таблиц переписок и диалогов должно происходить в связке с FetchedResultsController'ом. 

**Решение:**
> На данном этапе я начал понимать, в чем преимущество кор даты. FRC открывает большие возможности по оптимизации и скорости работы с большими данными. Самое сложное тут было - это понять, куда его засунуть). Его дизайн подразумевает тесную связь с таблицей, но он не может находится внутри Вью-контроллера - это нарушит принципы SOLID. Я решил создать отдельный объект - провайдер. Который записывает изменения от FRC и передает их через вью-модель.  
В этой неделе я также взялся за рефактор. До этого момента модули собирались в роутере, что было очень неправильно. Я написал некоторый AppAssembler, который хранит в себе несколько фабрик модулей и DIContainer, энкапсулирует эти модули для удобного доступа и контроля жизненного цикла.  
Превью есть в пул реквесте: [Pull Request (FRC)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/8)
</details>

<details> 
  <summary>Week #9</summary>

**Задача:**
> Провести рефактор приложения, соблюдая принципы DRY, KISS, SOLID (без OLI почему-то 🤔). Провести реструктуризацию согласно слоистой архитектуре SOA (Service-Oriented Architecture).  

**Решение:**
> По большей степени (я надеюсь) у меня было все более менее нормально. Я всегда старался придерживаться этим принципам. Конечно же, я провел некоторый рефакторинг. Разбил жирные контроллеры на более мелкие, чтобы придерживаться лимита строк файлов. Вынес логику обсервинга клавиатуры в протокол KeyboardObserving. Включил ThreadSanitizer, нашел один RaceCondition, пофиксил его.  
На данном этапе моя идея с анимированным выползающим снизу модальным экраном использовалась в 2 местах и намечался еще один модуль, где понадобилась бы подобная логика. Поэтому, я решил создать PopupViewController, который наследуется от UIViewController'а и добавляет переданному вью popUp эффект и обрабатывает закрытие. Теперь в нем можно изменять эффект блура, интенсивность, а главное какую часть экрана занимает вьюшка при всплытии.   
Самое сложное тут организовать нормальную структуру папок. Не всегда однозначно понятно что должно быть в Service, а что в Core. 
Для ясности, я нарисовал [диаграмму](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=ChatApp.drawio#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1VLk0w6UehciFC4I1cirhtFH3Cdkqbumy%26export%3Ddownload), жаль фидбека я по ней не получил.  
Я уверен, что с точки зрения архитектуры, в моем проекте много недочетов. С каждой новой фичей хочется все переписать, совершенно по-другому). Вайпер все больше начинает симпатизировать. Кажется, что с ним не было бы никаких проблем), но конечно же и без него можно сделать все грамотно. 
[Ссылка на Pull Request (Architecture)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/10)
</details>

<details> 
  <summary>Week #10</summary>

**Задача:**
> Написать экран выбора аватарки, где картинки подгружаются из интернета. Переиспользовать этот экран для выбора картинки, которую можно отправить личным сообщением. Сделать так, чтобы сообщения содержащие ссылку на картинку отображали эту картинку в ячейке таблицы. 

**Решение:**
> Задача довольно большая. Наверное, самая большая из всех. Лектор хотел еще добавить сюда SwiftConcurrency дополнительным заданием, но в итоге отказался. Я бы не прочь испытать эту штуку, она очень удобная, но в этом проекте установили требование в iOS 12 и поднимать таргет я очень не хочу. Иначе вся боль поддержки 12 iOS будет напрасной), У меня было желание сделать какой-нибудь дополнительный компонент с использование asyncawait под available модификатором, но дублировать все слишком заморочно и времени на это не хватило в итоге.  
> Суть задачи делится на 3 части:  
> 1. Сделать переиспользуемый экран с collectionView, который отображает картинки и позволяет их выбирать
> 2. Сделать network core слой и сервисы к нему. 
> 3. Сделать логику, которая будет обрабатывать текст на наличие ссылок, асинхронно загружать картинки и отображать их в ячейках таблицы диалогов под сообщениями.  
>
> В первом пунке единственной сложностью (которую я придумал себе сам) был кастомный лаяут collectionView. Мне не хотелось делать стандартный квадратный грид, мне понравился [PinterestLayout](https://cocoacontrols-production.s3.amazonaws.com/uploads/control_image/image/12324/Pinterest_layout.jpg), где ячейки в одной строке не имеют одинаковую высоту, а рассчитываются динамически.  
> Второй пункт я реализовал написанием следующих компонентов:  
> - RequstConfig, который состоит из Request и Parser. (Request формирует запрос, а парсер приводит ответ в нужную форму)
> - RequestDispatcher, который создает нетворк таску в заданной сессии, запускает и возвращает ее. В комплишене выдает ответ, распаршенный с помощью Parser'а.
> - NetworkOperation, который оперирует тасками с помощью диспетчера. Имеет возможность отменить таску.
> - URLImageFetchable и CachedImageFetcher, которые занимаются загрузкой изображений и их кешированием. 
>
> Третий пункт я реализовал с помощью сущности ImageRetriever. В ней существует одна функция, которая получает текст и если в нем есть ссылка - возвращает текст без этой ссылки, но с картинкой. Если же картинку загрузить не удалось, то возвращает ответ, в зависимости от выбранной конфигурации. Т.е. может вернуть дефолтное изображение или текст с ошибкой. Логика такова: когда ячейка отображается вызывается updateCell, и текст передается imageRetriever'у. После получения картинки она устанавливается в ячейку. Если картинку загрузить не удалось выводится сообщение об ошибке в скобках после ссылки. Все картинки кешируются, чтобы не грузиться повторно при скролле туда-сюда.  
Это решение не идеально, так-как содержит ряд проблем. Во первых, размер ячейки перерасчитывается динамически, после отрисовки картинки, из-за чего таблица неприятно скачет при скролле. Во-вторых, так-как поиск ссылки в тексте происходит асинхронно, иногда могут возникнуть проблемы, когда картинку получит не та ячейка, что должна. Решение требует либо логики, при которой сервер отправляет атачменты отдельно с указанием размера картинки (тогда можно выделить место и заполнить его activity indicator'ом), либо начинать парсить текст заранее, до появления на экране, что требует FRC выдать текст раньше, следовательно потребуется 2 dataSource'а? Ни одно из решений мне не показалось реализуемым в такие сроки, поэтому пока что остается текущий вариант...   
Превью есть в пул реквесте: [Pull Request (Network)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/11)
</details>

<details> 
  <summary>Week #11</summary>

**Задача:**
> Реализовать дрожащую кнопку (при повторном нажатии плавно возвращается в нормальное состояние). Реализовать эмитер гербов Тинькофф из под пальца на длинное нажатие на любом экране. 

**Решение:**
> Первая часть задания довольно проста, хотя я долго с ней провозился. Я задал 2 кейфрейма, -5 и 5 за 0.3 секунды, что вроде-бы должно работать, но выглядело это намного медленнее, чем на примере. Потом до меня дошло, что в примере задается 0, -5, 0, 5, 0, что за 0.3 секунды, естественно, выглядит намного быстрее.  
Вторая часть более сложная. Подсказки что использовать эмитер нигде не было, поэтому к этому надо было прийти самому). У самого эмитера очень много непонятных свойств, поэтому до нужного эффекта добраться можно только путем исследования). В итоге, я создал класс LongPressLogoEmitter. При инициализации он принимает drawingView (где рисовать гербы и обрабатывать нажатия), создает gestureRecognizer на лонг тап и обрабатывает его же ивенты. Его можно включить (добавить лейер и включить обработчик) и выключить (удалить лейер и выключить обработчик). При первоначальном прикосновении layer с эмитерем помещается поверх вьюшки (чтобы его всегда было видно). Эмитеру задается лайфтайм, т.е. гербы начинают появлятся и задается локация прикосновения относительно drawingView, чтобы рисовать гербы именно там, где сейчас палец. При смене позиации пальца локация обновляется. При отмене лайфтайм эмитера устанавливается в 0, что убирает дальнейшую генерацию гербов, но оставляет текущую анимацию догорать, что выглядит красиво.  
Первоначально, я хотел удалять слой эмитера при убирании пальца, но в таком случае все летающие гербы резко исчезали и это было не красиво. Поэтому я решил оставить слой и просто менять lifetime эмитера.  
Превью есть в пул реквесте: [Pull Request (Animations)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/12)
</details>

<details> 
  <summary>Week #12</summary>

**Задача:**
> Написать не меньше двух unit-тестов на сервисный слой приложения. Проверить, что вызываются нужные методы core-слоя с нужными параметрами. Написать UI-тест, проверяющий, что на экране профиля есть два поля ввода (введенный текст проверять не нужно).

**Решение:**
> Покрыл тестами самый сложный на мой взгляд компонент - ImageRetriever, там много всякой логики и есть где применить тест-даблы. Написал сначала тесты на LinksDetectingProtocol, что занимается поиском ссылок на картинки в тексте, затем на сам ImageRetriever. ImageRetriever принимает на вход imageFetcher, поэтому его пришлось мокать. Получилось прикольно, нашел даже баг. Вообще, прочитал про TDD - классная штука, помогает избежать многих ошибок.  
В UI тесте просто перешел на экран профиля, посчитал текст филды и текст вью, чтобы их было больше 2. Очень простое задание)
Превью есть в пул реквесте: [Pull Request (Tests)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/13)
</details>

<details> 
  <summary>Week #13</summary>

**Задача:**
> Создать конфигурационные файлы, настроить билд и тест проекта через фастлейн и github actions. Кидать в дискорд нотификейшены по итогу сборки.

**Решение:**
> Интересное задание. Наконец можно было закрыть икскод и поработать в VSCode)). Вынес конфиги в 3 файла Base, Debug, Release. Сделал так, потому что в икскоде уже стояли PODовские конфиги и чтобы их не ломать импортировал их в Debug и Release соответственно, добавив сверху Base конфиг, в котором все переменные проекта. Создал ConfigurationReader для чтения параметров конфигов из Info.plist. Установил бандлер, фастлейн, написал лейны для билда, линтинга и тестов. Написал экшн на гитхабе, который помимо экзекьюта этих лейнов кидает нотификейшн в канал дискорда.  
За 4 часа до дедлайна ранер препода сдох и пришлось быстренько делать свой. Мой старенький макбук все еще могет! 20 минут пыхтит правда)
[Ссылка на Pull Request (CI)](https://github.com/TFS-iOS/chat-app-taymasoff/pull/13)
</details>
