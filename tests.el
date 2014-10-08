;;; tests  -*- lexical-binding: t -*-

(require 'ert)

(ert-deftest diary-server/date-list ()
  "Test the date listing works on the test file."
  (noflet ((current-time () ; time travel
             (apply
              'encode-time
              (parse-time-string "2014-09-28 11:46:00 55"))))
    (let ((org-agenda-files `("./diarytest.org"))) ; need better locator than ./
      (should
       (equal
        '("2014-10-2" "test one")
        (match
         (aref (diary-server/date-list :daystart :today) 0)
         ((alist "date" date "head" head) (list date head)))))
      (should 
       (equal
        '("2014-11-15" "test two")
        (match 
         (aref (diary-server/date-list :daystart "2014-11-06") 0)
         ((alist "date" date "head" head) (list date head))))))))

;;; tests.el ends here
