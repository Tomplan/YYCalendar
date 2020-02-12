//
//  NormalCalendar.swift
//  Pods
//
//  Created by 60029596 on 31/07/2019.
//

import UIKit

@available(iOS 10.0, *)
@objcMembers public class NormalCalendar: UIViewController {

    
    // MARK: - UI Property
    var previousWindow: UIWindow!
    var contentViewWindow: UIWindow!
    var backgroundView: UIView!
    var contentView: UIView!
    var headerView: UIView!
    var bodyView: UIView!
    var lineSeparatorView: UIView!
    var yearLabel: UILabel!
    var monthLabel: UILabel!
    var closeButton: UIButton!
    var yearLeftButton: UIButton!
    var yearRightButton: UIButton!
    var monthLeftButton: UIButton!
    var monthRightButton: UIButton!
    var selectMonthYearStackView: UIStackView!
    var weekStackView: UIStackView!
    var dayStackView: UIStackView!

    // MARK: - Calendar Style
    var dayButtonStyle: DayButtonStyle = .roundishSquare
    var hideDuration: Double = 0.3
    var dimmedBackgroundColor: UIColor = UIColor.black
    var dimmedBackgroundAlpha: CGFloat = 0.5
    var headerViewBackgroundColor: UIColor = Useful.getUIColor(245, 245, 245)
    var bodyViewBackgroundColor: UIColor = Useful.getUIColor(255, 255, 255)
    var sundayColor: UIColor = Useful.getUIColor(235, 61, 79)
    var disabledSundayColor: UIColor = Useful.getUIColor(251, 197, 202)
    var saturdayColor: UIColor = Useful.getUIColor(53, 113, 214)
    var disabledSaturdayColor: UIColor = Useful.getUIColor(194, 212, 243)
    var defaultDayColor: UIColor = Useful.getUIColor(51, 51, 51)
    var disabledDefaultDayColor: UIColor = Useful.getUIColor(193, 193, 193)
    var lineSeparatorColor: UIColor = Useful.getUIColor(233, 233, 233)
    var selectedDayColor: UIColor = Useful.getUIColor(55, 137, 220)
//    var headerLabelFont: UIFont = UIFont.systemFont(ofSize: 24)
    var headerLabelFont: UIFont = UIFont(name: "Helvetica", size: 20.0)!
    var headerLabelBackgroundColor: UIColor = UIColor.darkGray
    var headerLabelTextColor: UIColor = UIColor.black
    var weekLabelFont: UIFont = UIFont.systemFont(ofSize: 16)
    var weekLabelBackgroundColor: UIColor = UIColor.darkGray
    var weekLabelTextColor: UIColor = UIColor.black
    var dayLabelFont: UIFont = UIFont.systemFont(ofSize: 19)
    var dayLabelBackgroundColor: UIColor = UIColor.darkGray
    var dayLabelTextColor: UIColor = UIColor.black

    var dayArray: [String] = []
    var dayButtonArray: [DayButton] = []
    var dayStackViewArray: [UIStackView] = []

    var todayLabel: UILabel = UILabel()
    var todayButton: UIButton = UIButton()

    var tapOutsideTouchGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()

    public var allowTouchOutsideToDismiss: Bool = true {
        didSet {
            weak var weakSelf = self
            if let weakSelf = weakSelf {
                if allowTouchOutsideToDismiss == true {
                    weakSelf.tapOutsideTouchGestureRecognizer.addTarget(weakSelf, action: #selector(dismissView))
                } else {
                    weakSelf.tapOutsideTouchGestureRecognizer.removeTarget(weakSelf, action: #selector(dismissView))
                }
            }
        }
    }

    // MARK: - Data Property
    public var selectHandler: SelectHandler?
    public var inquiryDate: Date = Date() // input date from client
    public var dateFormat: String = "" // input date format from client
    public var langType: LangType = .ENG // default value is English
    var calendar: Calendar = Calendar(identifier: .iso8601)
    var weekArray: [String] = ENG_WEEK

    // Detached from inquiryDate
    var inputYear: Int = 0
    var inputMonth: Int = 0
    var inputDay: Int = 0
    var lastDay: Int = 0

    // In order to draw calendar
    var firstWeekDay: Int = 0
    var lastWeekDay: Int =  0
    var isTodayMonth: Bool = false
    var isdisabledMonth: Bool = false
    var todayYear: Int = Calendar.current.component(.year, from: Date())
    var todayMonth: Int = Calendar.current.component(.month, from: Date())
    var todayDay: Int = Calendar.current.component(.day, from: Date())

    // MARK: - Initialization
    public init(langType type: LangType, date: String, format: String, completion selectHandler: @escaping SelectHandler) {
        super.init(nibName: nil, bundle: nil)
        self.langType = type
        self.dateFormat = format
        self.inquiryDate = Useful.stringToDate(date, format: self.dateFormat) ?? Date()
        self.selectHandler = selectHandler

        self.setupLangType()
        self.setupDate()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Cannot use when keywindow is nil
    func viewNotReady() -> Bool {
        return UIApplication.shared.keyWindow == nil
    }

    // MARK: - Setup
    // Week label can be changed by selecting langType
    func setupLangType() {
        switch self.langType {
        case .ENG:
            self.weekArray = ENG_WEEK
        case .ENG2:
            self.weekArray = ENG2_WEEK
        case .ENG3:
            self.weekArray = ENG3_WEEK
        case .KOR:
            self.weekArray = KOR_WEEK
        case .JPN:
            self.weekArray = JPN_WEEK
        case .CHN:
            self.weekArray = CHN_WEEK
        }
    }

    // Set date componet by detaching from inquiryDate
    func setupDate() {
        self.calendar.locale = Locale(identifier: "en_BE")
//        print("*********************************")
//        print("self.inquiryDate: ", self.inquiryDate)
        self.inputYear = self.calendar.component(.year, from: self.inquiryDate)
        self.inputMonth = self.calendar.ordinality(of: .month, in: .year, for: self.inquiryDate)!
        self.inputDay = self.calendar.ordinality(of: .weekday, in: .weekOfYear, for: self.inquiryDate)!
        self.lastDay = self.calendar.component(.day, from: self.inquiryDate.endOfMonth())
        self.firstWeekDay = self.calendar.ordinality(of: .weekday, in: .weekOfYear, for: self.inquiryDate.startOfMonth())!
        self.lastWeekDay = self.calendar.ordinality(of: .weekday, in: .weekOfYear, for: self.inquiryDate.endOfMonth())!
        // Do inputMonth include today?
        if self.todayMonth == self.inputMonth && self.todayYear == self.inputYear {
            self.isTodayMonth = true
        } else {
            self.isTodayMonth = false
        }

        // Is this month after todayMonth?
        if self.todayYear < self.inputYear {
            self.isdisabledMonth = true
        } else {
            if self.todayMonth < self.inputMonth && self.todayYear == self.inputYear {
                self.isdisabledMonth = true
            } else {
                self.isdisabledMonth = false
            }
        }
    }

    func setupWindow() {
        if viewNotReady() {
            return
        }

        let window = UIWindow(frame: (UIApplication.shared.keyWindow?.bounds)!)
        self.contentViewWindow = window
        self.contentViewWindow.backgroundColor = UIColor.clear
        self.contentViewWindow.rootViewController = self
        self.previousWindow = UIApplication.shared.keyWindow
    }

    func setupViews() {
        if viewNotReady() {
            return
        }

        self.view = UIView(frame: (UIApplication.shared.keyWindow?.bounds)!)

        // Setup Gesture
        if allowTouchOutsideToDismiss == true {
            self.tapOutsideTouchGestureRecognizer.addTarget(self, action: #selector(dismissView))
        }

        // Setup Background
        self.backgroundView = UIView.init()
        self.backgroundView.addGestureRecognizer(self.tapOutsideTouchGestureRecognizer)
        self.backgroundView.backgroundColor = self.dimmedBackgroundColor
        self.backgroundView.alpha = self.dimmedBackgroundAlpha
        self.view.addSubview(self.backgroundView)

        // Setup ContentView
        self.contentView = UIView.init()
        self.contentView.backgroundColor = UIColor.white
        self.contentView.clipsToBounds = true
        self.view.addSubview(self.contentView)

        // Setup HeaderView
        self.headerView = UIView.init()
        self.headerView.backgroundColor = self.headerViewBackgroundColor
        self.headerView.clipsToBounds = true
        self.contentView.addSubview(self.headerView)

        // Setup lineSeparatorView
        self.lineSeparatorView = UIView.init()
        self.lineSeparatorView.backgroundColor = self.lineSeparatorColor
        self.contentView.addSubview(self.lineSeparatorView)

        // Setup BodyView
        self.bodyView = UIView.init()
        self.bodyView.backgroundColor = self.bodyViewBackgroundColor
        self.bodyView.clipsToBounds = true
        self.contentView.addSubview(self.bodyView)

        // Setup CloseButton
        self.closeButton = UIButton.init(type: .custom)
        self.closeButton.setBackgroundImage(Image.forButton.close, for: .normal)
        self.closeButton.setBackgroundImage(Image.forButton.highlightedClose, for: .highlighted)
        self.closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        self.headerView.addSubview(self.closeButton)
        
        // Setup TodayButton TOM
        self.todayButton = UIButton.init(type: .roundedRect)
//        self.todayLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.todayButton.setTitle("   Today   ", for: .normal)
        self.todayButton.tintColor = UIColor.lightGray
        self.todayButton.backgroundColor = UIColor.darkGray
        self.todayButton.layer.cornerRadius = 10 // 0.25 * todayButton.frame.width
//            self.todayLabel.font = UIFont(name: "Helvetica", size: 16)
//        self.todayLabel.textColor = UIColor.lightGray
//        self.todayLabel.textAlignment = .center
//        self.todayLabel.numberOfLines = 1
//        self.todayLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            self.todayButton.addTarget(self, action: #selector(todayAction), for: .touchUpInside)
        self.todayButton.restorationIdentifier = "todaysMonth"
        self.todayButton.addTarget(self, action: #selector(changeMonthOrYear(_:)), for: .touchUpInside)
        
        // Setup Month, Year Label
        self.monthLabel = UILabel.init()
        self.yearLabel = UILabel.init()
        self.monthLabel.text = String(format: "%02d월", self.inputMonth)
        self.monthLabel.font = self.headerLabelFont
        self.monthLabel.backgroundColor = self.headerLabelBackgroundColor
        self.monthLabel.textColor = self.headerLabelTextColor
        self.yearLabel.text = String(format: "%d년", self.inputYear)
        self.yearLabel.font = self.headerLabelFont
        self.yearLabel.backgroundColor = self.headerLabelBackgroundColor
        self.yearLabel.textColor = self.headerLabelTextColor
        
        // Setup Month, Year Select Button
        self.yearLeftButton = UIButton.init(type: .custom)
        self.yearRightButton = UIButton.init(type: .custom)
        self.monthLeftButton = UIButton.init(type: .custom)
        self.monthRightButton = UIButton.init(type: .custom)
        self.yearLeftButton.setImage(Image.forButton.leftArrow, for: .normal)
        self.yearLeftButton.setImage(Image.forButton.highlightedLeftArrow, for: .highlighted)
        self.yearRightButton.setImage(Image.forButton.rightArrow, for: .normal)
        self.yearRightButton.setImage(Image.forButton.highlightedRightArrow, for: .highlighted)
        self.monthLeftButton.setImage(Image.forButton.leftArrow, for: .normal)
        self.monthLeftButton.setImage(Image.forButton.highlightedLeftArrow, for: .highlighted)
        self.monthRightButton.setImage(Image.forButton.rightArrow, for: .normal)
        self.monthRightButton.setImage(Image.forButton.highlightedRightArrow, for: .highlighted)
        self.yearLeftButton.restorationIdentifier = "previousYear"
        self.yearRightButton.restorationIdentifier = "nextYear"
        self.monthLeftButton.restorationIdentifier = "previousMonth"
        self.monthRightButton.restorationIdentifier = "nextMonth"
        self.yearLeftButton.addTarget(self, action: #selector(changeMonthOrYear(_:)), for: .touchUpInside)
        self.yearRightButton.addTarget(self, action: #selector(changeMonthOrYear(_:)), for: .touchUpInside)
        self.monthLeftButton.addTarget(self, action: #selector(changeMonthOrYear(_:)), for: .touchUpInside)
        self.monthRightButton.addTarget(self, action: #selector(changeMonthOrYear(_:)), for: .touchUpInside)

        // Setup SelectMonthYear StackView
        self.selectMonthYearStackView = UIStackView.init()
        self.selectMonthYearStackView.axis = .horizontal
        self.selectMonthYearStackView.spacing = 2
        self.selectMonthYearStackView.addArrangedSubview(self.monthLeftButton)
        self.selectMonthYearStackView.addArrangedSubview(self.monthLabel)
        self.selectMonthYearStackView.addArrangedSubview(self.monthRightButton)
        self.selectMonthYearStackView.addArrangedSubview(self.yearLeftButton)
        self.selectMonthYearStackView.addArrangedSubview(self.yearLabel)
        self.selectMonthYearStackView.addArrangedSubview(self.yearRightButton)
        self.headerView.addSubview(self.selectMonthYearStackView)

        // Setup Week StackView
        self.weekStackView = UIStackView.init()
        self.weekStackView.axis = .horizontal
        self.weekStackView.spacing = 0
        self.weekStackView.distribution = .fillEqually

        for index in 0..<7 {
            let tempLabel = UILabel.init()
            tempLabel.textAlignment = .center
            tempLabel.font = self.weekLabelFont
            tempLabel.textColor = self.defaultDayColor
            tempLabel.text = self.weekArray[index]

            if index == 6 {
                tempLabel.textColor = self.sundayColor
            } else if index == 5 {
                tempLabel.textColor = self.saturdayColor
            }

            self.weekStackView.addArrangedSubview(tempLabel)
        }

        self.headerView.addSubview(self.weekStackView)

        // Setup Day
        self.dayStackView = UIStackView.init()
        self.dayStackView.axis = .vertical
        self.dayStackView.spacing = 0
        self.dayStackView.distribution = .fillEqually

        for row in 1...6 {
            let tempStackView = UIStackView.init()
            tempStackView.axis = .horizontal
            tempStackView.spacing = 0
            tempStackView.distribution = .fillEqually

            for column in 1...7 {
                let tempButton = DayButton(style: dayButtonStyle)
                tempButton.translatesAutoresizingMaskIntoConstraints = false
                tempButton.heightAnchor.constraint(equalTo: tempButton.widthAnchor).isActive = true
                tempButton.titleLabel?.font = self.dayLabelFont
                tempButton.selectedDayColor = self.selectedDayColor

                if column == 7 { // Sunday
                    tempButton.setTitleColor(self.sundayColor, for: .normal)
                } else if column == 6 { // Saturday
                    tempButton.setTitleColor(self.saturdayColor, for: .normal)
                } else { // Weekday
                    tempButton.setTitleColor(self.defaultDayColor, for: .normal)
                }

                tempButton.setTitle("", for: .normal)
                tempButton.tag = row * 10 + column
                tempButton.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)

                tempStackView.addArrangedSubview(tempButton)
            }

            self.dayStackView.addArrangedSubview(tempStackView)
        }

        self.bodyView.addSubview(self.dayStackView)
        self.bodyView.addSubview(self.todayButton)

    }

    func setupAutoLayout() {
        // Use Autolayout
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.lineSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.bodyView.translatesAutoresizingMaskIntoConstraints = false
        self.monthLabel.translatesAutoresizingMaskIntoConstraints = false
        self.yearLabel.translatesAutoresizingMaskIntoConstraints = false
        self.weekStackView.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.todayButton.translatesAutoresizingMaskIntoConstraints = false
        self.monthLeftButton.translatesAutoresizingMaskIntoConstraints = false
        self.monthRightButton.translatesAutoresizingMaskIntoConstraints = false
        self.yearLeftButton.translatesAutoresizingMaskIntoConstraints = false
        self.yearRightButton.translatesAutoresizingMaskIntoConstraints = false
        self.selectMonthYearStackView.translatesAutoresizingMaskIntoConstraints = false
        self.dayStackView.translatesAutoresizingMaskIntoConstraints = false

        // BackgroundView
        self.backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        // ContentView
        self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        // HeaderView
        self.headerView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.headerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.headerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true

        // LineSeparatorView
        self.lineSeparatorView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor).isActive = true
        self.lineSeparatorView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor).isActive = true
        self.lineSeparatorView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor).isActive = true
        self.lineSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // BodyView
        self.bodyView.topAnchor.constraint(equalTo: self.lineSeparatorView.bottomAnchor).isActive = true
        self.bodyView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.bodyView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.bodyView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

        // Close Button
        self.closeButton.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 3).isActive = true
        self.closeButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -3).isActive = true
        self.closeButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        self.closeButton.widthAnchor.constraint(equalTo: self.closeButton.heightAnchor).isActive = true

        
        // Month, Year Select Button
//        self.yearLeftButton.heightAnchor.constraint(equalToConstant: 35)
//        self.yearLeftButton.widthAnchor.constraint(equalToConstant: 30)
//        self.yearRightButton.heightAnchor.constraint(equalToConstant: 35)
//        self.yearRightButton.widthAnchor.constraint(equalToConstant: 30)
//        self.monthLeftButton.heightAnchor.constraint(equalToConstant: 35)
//        self.monthLeftButton.widthAnchor.constraint(equalToConstant: 30)
//        self.monthRightButton.heightAnchor.constraint(equalToConstant: 35)
//        self.monthRightButton.widthAnchor.constraint(equalToConstant: 30)

        // SelectMonthYear StackView
        self.selectMonthYearStackView.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 20).isActive = true
        self.selectMonthYearStackView.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor).isActive = true
        self.selectMonthYearStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Week StackView
        self.weekStackView.topAnchor.constraint(equalTo: self.selectMonthYearStackView.bottomAnchor).isActive = true
        self.weekStackView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 11).isActive = true
        self.weekStackView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -11).isActive = true
        self.weekStackView.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor).isActive = true
        self.weekStackView.heightAnchor.constraint(equalToConstant: 35).isActive = true

        // Day StackView
        self.dayStackView.topAnchor.constraint(equalTo: self.weekStackView.bottomAnchor, constant: 6).isActive = true
        self.dayStackView.leadingAnchor.constraint(equalTo: self.bodyView.leadingAnchor, constant: 11).isActive = true
        self.dayStackView.trailingAnchor.constraint(equalTo: self.bodyView.trailingAnchor, constant: -11).isActive = true
        self.dayStackView.bottomAnchor.constraint(equalTo: self.bodyView.bottomAnchor, constant: -14).isActive = true
        
        // TodayButton TOM
        self.todayButton.bottomAnchor.constraint(equalTo: self.bodyView.bottomAnchor, constant: -15).isActive = true
        self.todayButton.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor, constant: 0).isActive = true
    }

    func setupCalendar() {
        setLabel() // set year and month label
        setDayArray() // set day to dayArray from 1 to lastDay(28, 30, 31) of this month

        // Setup DayButton
        for case let verticalStackView as UIStackView in self.bodyView.subviews {
            for case let horizontalStackView as UIStackView in verticalStackView.subviews {
                for case let button as DayButton in horizontalStackView.subviews {
                    let row = button.tag / 10
                    let weekDay = button.tag % 10
                    let day = self.dayArray.first

                    setTodayIcon(button: button, day: day) // mark today icon (red dot)

                    if row == 1 {
                        if weekDay < self.firstWeekDay { // befroe 1st day in first week
                            button.setTitle("", for: .normal)
                            button.isEnabled = false
                        } else {
                            button.setTitle(day, for: .normal)
                            button.isEnabled = true
                            self.dayArray.removeFirst()
                        }
                    } else {
                        if day != nil {
                            button.setTitle(day, for: .normal)
                            button.isEnabled = true

                            self.dayArray.removeFirst()
                        } else {
                            // after last day in 6th week
                            button.setTitle("", for: .normal)
                            button.isEnabled = false

                            if row == 6 {
                                if weekDay == 7 { // if 6th week is empty
                                    horizontalStackView.isHidden = false
                                    return
                                } else {
                                    horizontalStackView.isHidden = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    private func getMonthName(inputMonth: Int) -> String {
        switch inputMonth {
        case 1: return "Jan"
        case 2: return "Feb"
        case 3: return "Mar"
        case 4: return "Apr"
        case 5: return "May"
        case 6: return "Jun"
        case 7: return "Jul"
        case 8: return "Aug"
        case 9: return "Sep"
        case 10: return "Oct"
        case 11: return "Nov"
        case 12: return "Dec"
        default: return ""

        }
    }
    
    // set year and month label
    func setLabel() {
        let monthName = getMonthName(inputMonth: self.inputMonth)
        
        self.monthLabel.text = monthName

        
        
        self.yearLabel.text = String(format: "%d", self.inputYear)
//        self.monthLabel.text = String(format: "%02d", self.inputMonth)
    }

    // set day to dayArray from 1 to lastDay(28, 29 ,30, 31) of month
    func setDayArray() {
        for day in 1...self.lastDay {
            self.dayArray.append(String(day))
        }
    }

    // mark today icon (red dot)
    func setTodayIcon(button: DayButton, day: String?) {
        let todayString = Useful.intToString(self.todayDay)

        if isTodayMonth && day == todayString {
            print("todayString: ", todayString)
            print("isTodayMonth: ", isTodayMonth)

            button.beforeTextColor = UIColor.red
            button.backgroundColor = UIColor.darkGray
            button.todayIconImageView.isHidden = true
        } else {
            button.todayIconImageView.isHidden = true
            button.beforeTextColor = UIColor.white
            button.backgroundColor = UIColor.clear
        }
    }

    // MARK: - Click Event
    @objc func changeMonthOrYear(_ sender: UIButton) {
        switch sender.restorationIdentifier {
        case "todaysMonth":
            self.inquiryDate = Date()
        case "previousMonth":
            self.inquiryDate = Useful.addDate(self.inquiryDate, year: 0, month: -1, day: 0) ?? Date()
        case "nextMonth":
            self.inquiryDate = Useful.addDate(self.inquiryDate, year: 0, month: 1, day: 0) ?? Date()
        case "previousYear":
            self.inquiryDate = Useful.addDate(self.inquiryDate, year: -1, month: 0, day: 0) ?? Date()
        case "nextYear":
            self.inquiryDate = Useful.addDate(self.inquiryDate, year: 1, month: 0, day: 0) ?? Date()
        default:
            break
        }

        self.setupDate()
        self.setupCalendar()
    }

    @objc func selectDayButton(_ sender: UIButton) {
        if let day = sender.titleLabel?.text {
            var component = self.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.inquiryDate)
            component.day = Int(day) ?? 1

            if let selectedDate = self.calendar.date(from: component) {
                let formattedDate = Useful.dateToString(selectedDate, format: self.dateFormat)
                if let handler = self.selectHandler {
                    handler(formattedDate)
                    self.dismissView()
                }
            }
        }
    }

    // MARK: - Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - NormalCalendar Usage
    public func show() {
        DispatchQueue.main.async {
            if self.viewNotReady() {
                return
            }

            self.setupViews()
            self.setupWindow()
            self.setupAutoLayout()
            self.setupCalendar()

            self.contentViewWindow.addSubview(self.view)
            self.contentViewWindow.makeKeyAndVisible()
        }
    }

    @objc public func todayAction() {
//        self.dismissView()
        self.setupViews()
        self.setupWindow()
        self.setupAutoLayout()
        self.setupCalendar()

        self.contentViewWindow.addSubview(self.view)
        self.contentViewWindow.makeKeyAndVisible()
    }
    @objc public func dismissView() {
        DispatchQueue.main.async {
            let completion = { (complete: Bool) -> Void in
                if complete {
                    self.view.removeFromSuperview()
                    self.contentViewWindow.isHidden = true
                    self.contentViewWindow = nil
                    self.previousWindow.makeKeyAndVisible()
                    self.previousWindow = nil
                }
            }

            self.view.alpha = 1

            UIView.animate(withDuration: self.hideDuration, animations: {
                self.view.alpha = 0
            }, completion: completion)
        }
    }
}
