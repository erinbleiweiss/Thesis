import psycopg2
import md5

from moot.base import Base

class UserAlreadyExistsException(Exception):
    def __init__(self, err):
        self.err = err
    def __str__(self):
        return 'Exception: ' + self.err

class NoUserExistsException(Exception):
    def __init__(self, err):
        self.err = err
    def __str__(self):
        return 'Exception: ' + self.err

class BadArgumentsException(Exception):
    """Exception for entering bad arguments"""
    def __init__(self, err):
        self.err = err
    def __str__(self):
        return 'Exception: ' + self.err

class MootDao(Base):

    def __init__(self):
        Base.__init__(self, __name__)

        self.dbname = self.config.get('psql', 'dbname')
        self.pgusername = self.config.get('psql', 'pgusername')
        self.pgpassword = self.config.get('psql', 'pgpassword')
        self.pghostname = self.config.get('psql', 'pghostname')


    def get_db(self):
        return psycopg2.connect(database=self.dbname,
                                user=self.pgusername,
                                password=self.pgpassword,
                                host=self.pghostname)


    def login(self, user_id, name):
        self.logger.debug("login()")
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            c.execute('SELECT COUNT(*) FROM gameuser WHERE user_id=%s', (user_id,))
            n = int(c.fetchone()[0])
            exists = (n > 0)
            if exists:
                return True
            else:
                c.execute('INSERT INTO gameuser (user_id, name) VALUES '
                          '(%s, %s)', (user_id, name))
                conn.commit()
                self.setup_points(user_id)
                return True


    def setup_points(self, user_id):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('INSERT INTO user_score (user_id, score_value) values '
                   '(%s, 0)')
            c.execute(cmd, (user_id,))
            conn.commit()


    def award_points(self, user_id, points):
        self.logger.debug("Awarding {0} points to user '{1}'".format(
            points, user_id))
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('update user_score set score_value=score_value+%s where '
                 'user_id=%s')
            conn.commit()
            c.execute(cmd, (points, user_id))
            cmd = ('insert into points_earned (user_id, score_value) values '
                   '(%s, %s)')
            c.execute(cmd, (user_id, points))
            conn.commit()

    def get_points(self, user_id):
        self.logger.debug("Getting points for {0}".format(user_id))
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('select score_value from user_score where user_id=%s')
            c.execute(cmd, (user_id,))
            points = c.fetchone()[0]
        return points

    def award_achievement(self, user_id, achievementname):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('insert into user_achievement (user_id, achievement_id, '
                   'created_at) values (%s, (select achievement_id from '
                   'achievement where name=%s), now());')
            self.logger.debug(cmd)
            c.execute(cmd, (user_id, achievementname))
            conn.commit()



    def get_achievement_info(self, achievementname):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('select description from achievement where name=%s')
            c.execute(cmd, (achievementname,))
            info = {}
            info["description"] = c.fetchone()[0]
        return info

    def get_achievements(self, user_id):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('select name, description, created_at from achievement, user_achievement '
                   'where achievement.achievement_id = user_achievement.achievement_id '
                   'and user_achievement.user_id=%s;')
            c.execute(cmd, (user_id,))
            achievements = []
            for row in c.fetchall():
                d = {}
                d["name"] = row[0]
                d["description"] = row[1]
                d["created_at"] = row[2]
                achievements.append(d)
        return achievements

    def get_unearned_achievements(self, user_id):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('SELECT name, description FROM achievement a WHERE NOT '
                   'EXISTS (SELECT 1 FROM user_achievement u '
                   'WHERE u.user_id=%s and a.achievement_id = '
                   'u.achievement_id );')
            c.execute(cmd, (user_id,))
            achievements = []
            for row in c.fetchall():
                d = {}
                d["name"] = row[0]
                d["description"] = row[1]
                achievements.append(d)
        return achievements


    def save_product(self, user_id, upc, product_name, color, type):
        conn = self.get_db()
        if len(product_name) > 120:
            product_name = product_name[0:120]
        with conn:
            c = conn.cursor()
            cmd = ('insert into scanned_product (user_id, upc, product_name, '
                   'color, type, date) values (%s, %s, %s, %s, %s, now())')
            c.execute(cmd, (user_id, upc, product_name, color, type))
            conn.commit()


    def get_products(self, user_id):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('select product_name, color, type, date from '
                   'scanned_product where user_id=%s')
            c.execute(cmd, (user_id,))
            products = []
            for row in c.fetchall():
                d = {}
                d["product_name"] = row[0]
                d["color"] = row[1]
                d["type"] = row[2]
                d["date"] = row[3]
                products.append(d)
            return products

    def get_high_scores(self, num_scores):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            if num_scores == "0":
                cmd = ('select name, row_number() over (order by score_value '
                       'desc, gameuser.created_at), score_value, '
                       'gameuser.user_id from user_score, gameuser where '
                       'user_score.user_id=gameuser.user_id order by '
                       'score_value desc')
                c.execute(cmd)
            else:
                cmd = ('select name, row_number() over (order by score_value '
                       'desc, gameuser.created_at), score_value, '
                       'gameuser.user_id from user_score, gameuser where '
                       'user_score.user_id=gameuser.user_id order by '
                       'score_value desc limit %s')
                c.execute(cmd, (num_scores,))
            scores = []
            for row in c.fetchall():
                d = {}
                d["name"] = row[0]
                d["rank"] = row[1]
                d["score"] = row[2]
                d["uuid"] = row[3]
                scores.append(d)
            return scores

    def edit_name(self, user_id, name):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('update gameuser set name=%s where user_id=%s')
            c.execute(cmd, (name, user_id))
            conn.commit()

    def get_name(self, user_id):
        conn = self.get_db()
        with conn:
            c = conn.cursor()
            cmd = ('select name from gameuser where user_id=%s')
            c.execute(cmd, (user_id,))
            name = c.fetchone()[0]
        return name