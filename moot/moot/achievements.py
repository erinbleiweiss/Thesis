import ConfigParser
import logging
from logging.config import fileConfig

from base import Base
from mootdao import MootDao

class Achievements(Base):

    def __init__(self, user_id):
        Base.__init__(self, __name__)
        self.user_id = user_id
        self.config = ConfigParser.ConfigParser()
        self.config.read('config.ini')
        self.all_achievements = MootDao().get_achievements(self.user_id)

    def check_all_achievements(self):
        achievements_earned = []
        for attr in dir(self):
            if(attr.startswith('test_')):
                test = getattr(self, attr)
                test_result = test()
                try:
                    should_award = test_result[0]
                    achievement_name = test_result[1]
                    if should_award:
                        db = MootDao()
                        db.award_achievement(self.user_id, achievement_name)
                        self.logger.info("Awarded achievement '{0}' to user "
                                         "'{1}".format(achievement_name,
                                                       self.user_id))
                        achievements_earned.append(achievement_name)
                    else:
                        self.logger.info("Not awarding achievement '{0}' to "
                                          "user '{1}'".format(achievement_name,
                                                              self.user_id))
                except TypeError:
                    self.logger.critical("Problem with test result")
        return achievements_earned


    def is_new_achievement(self, achievement_name):
        """
        Determines whether an achievement is unearned for a particular user

        :param achievement_name: (String) corresponding to name in
        achievement table

        :return: True if user does not have the achievement
                 or False if user has already earned the achievement
        """
        for ach in self.all_achievements:
            if ach["name"] == achievement_name:
                return False
        return True


    def test_new_moot(self):
        """
        Tests whether user should be awarded "New Moot" Achievement

        :return:    Tuple in the form (Name, Boolean)
                    Name = String (corresponds to name in achievement table)
                    Boolean = Whether achievement should be awarded
        """
        self.logger.debug("test_new_moot()")
        name = "New Moot on the Block"
        if self.is_new_achievement(name):
            return (True, name)
        else:
            self.logger.debug("User '{0}' already earned '{1}'"
                              .format(self.user_id, name))
        return (False, name)

    def test_easy_as_abc(self):
        """
        Tests whether user should be awarded "Easy as ABC" Achievement

        :return:    Tuple in the form (Name, Boolean)
                    Name = String (corresponds to name in achievement table)
                    Boolean = Whether achievement should be awarded
        """
        self.logger.debug("test_easy_as_abc()")
        name = "Easy as ABC"
        if self.is_new_achievement(name):
            db = MootDao()
            products = db.get_products(self.user_id)
            all_letters = set()
            for p in products:
                first_letter = p["product_name"][0]
                if first_letter.isalpha():
                    all_letters.add(first_letter.upper())
                if len(all_letters) == 26:
                    return (True, name)
        else:
            self.logger.debug("User '{0}' already earned '{1}'"
                              .format(self.user_id, name))
        return (False, name)
