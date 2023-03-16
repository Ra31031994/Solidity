// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract projectFunding {
//נגדיר אובייקט עבור קמפיין. יורכב מכל התכונות שבסוגריים
    struct Campaign {
        address owner; //כתובת הארנק של יוצר הקמפיין
        string title; //כותרת הקמפיין
        string description; // תיאור הקמפיין
        uint256 target; //יעד כספי של הקמפיין
        uint256 deadline; //דדליין לסיום הקמפיין
        uint256 amountCollected; //כמות כסף שנאספה עד כה
        string image; //תמונה
        address[] donators; //מערך של כתובת הארנק של התורמים
        uint[] donations; //מערך של סכום של כל תורם
    }
    mapping(uint256 => Campaign) public campaigns; //יצירת טבלה שבעמודה השמאלית מספר רץ ובימנית שם הקמפיין
    uint256 public numberOfCampaigns = 0; //נגדיר משתנה כללי שיספור את מספר הקמפיינים

//פונקציה ליצירת קמפיין
//המשתמש יכול ליצור קמפיין כלומר להשתמש בפונ' זו לכן היא פבליק
//הפונ' מחזירה לבסוף את המספר הסידורי של הקמפיין שהוא מסוג יואינט256
//בסוגרים מוגדרים הפרמטרים אותם הפונ' צריכה לקבל
    function createCampaign(address _owner, string memory _title, string memory _description,uint256 _target,uint256 _deadline,string memory _image) public returns (uint256){ 
//נוסיף איבר בטבלת הקמפיינים (מאפינג) ע"י השורה הבאה
        Campaign storage campaign = campaigns[numberOfCampaigns];
//בדיקה אם הדדליין של הקמפיין לפני התאריך של היום נציג הודעת שגיאה
        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future");
//איכלוס המשתנים הפנימיים בתכונות הקמפיין
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;
//נעלה את מספר הקמפיינים הקיימים ב1
        numberOfCampaigns++;
//נחזיר את המספר הסידורי של הקמפיין
        return numberOfCampaigns - 1;
    }

//פונקציה להעברת כסף לקמפיין
//המשתמש יכול להשתמש בפונקציה הזו על מנת להעביר כסף לכן היא פבליק, המשתמש מעביר כסף ריפטוגרפי דרך הפונ' ולכן נגדיר אותה כפאייבל
    function donateToCampaign(uint256 _id) public payable {
        //נשלוף מתוך ההעברה את כמוך הכסף שהמשתמש רוצה להעביר ונכניס אותה למשתנה חדש - אמאונט
        uint256 amount = msg.value;
//נאתר את הקמפיין שהמשתמש הכניס את המספר הסידורי שלו מתוך רשימת הקמפיינים(מאפינג)
       Campaign storage campaign = campaigns[_id];
//לתוך רשימת התורמים של המקפיין תכניס תא כתובת התורם
        campaign.donators.push(msg.sender);
//הכנס לתוך רשימת הסכומים שנתרמו את הסכום שנתרם על ידי התורם שלנו
        campaign.donations.push(amount);
//בשורה זו מתבצעת הטראנזקציה. ניצור משתנה בוליאני שיבדוק האם נשלחה הטראנזקציה
//אנו שולחים ליוצר של הקמפיין את הערך אמאונט(כמות הכסף שרוצים לתרום)
        (bool sent,) = payable(campaign.owner).call{value: amount}("");
//אם ההעברה בוצעה בהצלחה, נוסיף לכמות שנאספה לקמפיין עד כה את הכמות שהתורם העביר כרגע
        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

//פונקציה שמחזירה את כל הרשימה של התורמים
//נקבל כקלט את האיידי של הקמפיין
//ה"ויו" אומר שזה מחזיר לנו נתונים לצפייה בלבד
//לפני שפותחים פונקציה צריך להגדיר את סוג המשתנה של מה שהולך לחזור - "returns(adress[]...)
//במקרה שלנו הסוגים הם מערך מסוג כתובות ומערך מסוג מספרים

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        //במקרה שלנו הסוגים הם מערך כתובות של התורמים ומערך סכומי התרומה
        return (campaigns[_id].donators, campaigns[_id].donations);
    }


//פונקציה שמחזירה רשימה של המקפיינים
//לא מקבלת פרמטרים כי רוצים להחזיר את כל הקמפיינים
//ה"ויו" אומר שזה מחזיר לנו נתונים לצפייה בלבד
//לפני שפותחים פונקציה צריך להגדיר את סוג המשתנה של מה שהולך לחזור - במקרה שלנו מערך של קמפיינים
    function getCampaigns() public view returns(Campaign[] memory) {
        //ניצור משתנה חדש מסוג מערך של קמפיינים. נכניס אליו מערך של קמפיינים חדש ריק בגודל מספר הקמפיינים שקיימים כיום 
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

//נעשה לולאה שבעצם תעבור על כל מספרי הקמפיינים במאפינג
//לאחר מכן כל קמפיין מהעמודה הימנית במאפינג נכנס לתוך אייטם
//ואז נכניס את אייטם למערך החדש אולקמפיינס
        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }
//מחזירה את כל הקמפיינים
        return allCampaigns;
    }
}
