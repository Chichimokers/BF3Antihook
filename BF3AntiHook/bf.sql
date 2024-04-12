-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Värd: 127.0.0.1
-- Tid vid skapande: 11 apr 2024 kl 23:23
-- Serverversion: 10.1.38-MariaDB
-- PHP-version: 5.6.40

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databas: `bf`
--

DELIMITER $$
--
-- Procedurer
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `40_UnlockPlayer` (IN `mPID` INT)  BEGIN

DECLARE mUnlocked TINYINT(1) DEFAULT '4';

SELECT unlocked into mUnlocked FROM a_emu_playerinfo WHERE user_id=mPID;


IF mUnlocked = 0 THEN

    INSERT INTO bf3_playerstats (pid, statname, value)
    SELECT mPID,statname,value FROM bf3_playerstatsunlock
    ON DUPLICATE KEY
    UPDATE value = bf3_playerstats.value+bf3_playerstatsunlock.value;

    CALL 45_ReRankPlayer(mPID);

	UPDATE a_emu_playerinfo SET unlocked = 3
    WHERE user_id=mPID;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `41_RemoveUnlockPlayer` (IN `mPID` INT)  NO SQL
BEGIN

DECLARE mUnlocked TINYINT(1) DEFAULT '4';

SELECT unlocked into mUnlocked FROM a_emu_playerinfo WHERE user_id=mPID;

IF mUnlocked = 3 THEN

    DELETE FROM bf3_playerstats USING bf3_playerstats,bf3_playerstatsunlock
    WHERE bf3_playerstats.statname=bf3_playerstatsunlock.statname
    AND bf3_playerstats.value=bf3_playerstatsunlock.value
    AND bf3_playerstats.pid=mPID; 

    UPDATE bf3_playerstats,bf3_playerstatsunlock
    SET bf3_playerstats.value=bf3_playerstats.value-bf3_playerstatsunlock.value
    WHERE bf3_playerstats.statname=bf3_playerstatsunlock.statname
    AND bf3_playerstats.value>bf3_playerstatsunlock.value
    AND bf3_playerstats.pid=mPID;

    CALL 45_ReRankPlayer(mPID);

	UPDATE a_emu_playerinfo SET unlocked = 0
    WHERE user_id=mPID;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `45_ReRankPlayer` (IN `mPID` INT)  BEGIN

DECLARE mScore FLOAT(20,5);
DECLARE mRank FLOAT;

SET mScore=0;

SELECT SUM(value) INTO mScore FROM bf3_playerstats,scorematrix WHERE bf3_playerstats.statname=scorematrix.statname AND pid=mPID;


IF mScore > 24370000 THEN SET mRank = 145;
ELSE
SELECT MIN(rank) INTO mRank FROM rankmatrix
WHERE score>mScore;
SET mRank=mRank-1;
END IF;

IF (mRank < 1) OR mRank IS NULL THEN DELETE FROM `bf3_playerstats` WHERE pid=mPID
AND statname='rank';
ELSE

INSERT INTO bf3_playerstats (pid, statname, value) VALUES(mPID,'rank',mRank)
ON DUPLICATE KEY
UPDATE value = mRank;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `50_UnlockAllPlayers` ()  BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE mPID INT;
DECLARE curseurPID CURSOR FOR SELECT DISTINCT user_id FROM a_emu_playerinfo
WHERE unlocked <> 3;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN curseurPID;
   
read_loop: LOOP
	FETCH curseurPID INTO mPID;
    		IF done THEN
			LEAVE read_loop;
		END IF;
        CALL 40_UnlockPlayer(mPID);
END LOOP;

CLOSE curseurPID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `51_RemoveUnlockAllPlayers` ()  BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE mPID INT;
DECLARE curseurPID CURSOR FOR SELECT DISTINCT user_id FROM a_emu_playerinfo
WHERE unlocked = 3;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN curseurPID;
   
read_loop: LOOP
	FETCH curseurPID INTO mPID;
    		IF done THEN
			LEAVE read_loop;
		END IF;
        CALL 41_RemoveUnlockPlayer(mPID);
END LOOP;

CLOSE curseurPID;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellstruktur `a_bf_dogtagssettings`
--

CREATE TABLE `a_bf_dogtagssettings` (
  `pid` bigint(255) NOT NULL,
  `client_type` varchar(255) NOT NULL DEFAULT '',
  `dta` bigint(20) NOT NULL DEFAULT '0',
  `dtb` bigint(20) NOT NULL,
  `clantag` varchar(255) NOT NULL DEFAULT '',
  `uatt` bigint(255) NOT NULL DEFAULT '0',
  `emblem` varchar(255) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumpning av Data i tabell `a_bf_dogtagssettings`
--

INSERT INTO `a_bf_dogtagssettings` (`pid`, `client_type`, `dta`, `dtb`, `clantag`, `uatt`, `emblem`) VALUES
(1, 'bf3_client', 247, 179, 'CLAN', 16976713875456, ''),
(1, 'bfbc2_client', 0, 0, 'CLAN', 0, ''),
(1, 'havana_client', 256, 263, 'CLAN', 17596599287886, ''),
(1, 'mohw_client', 657, 306, 'CLAN', 45153830043648, ''),
(1, 'warsaw_client', 218, 0, 'CLAN', 835662, '2019070824123365001'),
(2, 'bf3_client', 247, 179, 'CLAN', 16976713875456, ''),
(2, 'bfbc2_client', 0, 0, 'CLAN', 0, ''),
(2, 'havana_client', 256, 263, 'CLAN', 17596599287886, ''),
(2, 'mohw_client', 657, 306, 'CLAN', 45153830043648, ''),
(2, 'warsaw_client', 218, 0, 'CLAN', 835662, '2019070824123365011'),
(3, 'bf3_client', 247, 179, 'GANG', 16976715715463, ''),
(3, 'bfbc2_client', 0, 0, 'CLAN', 0, ''),
(3, 'havana_client', 256, 263, 'CLAN', 17596599287886, ''),
(3, 'mohw_client', 657, 306, 'CLAN', 45153830043648, ''),
(3, 'warsaw_client', 218, 0, 'CLAN', 835662, '2019070824123365001');

-- --------------------------------------------------------

--
-- Tabellstruktur `a_bf_emblems`
--

CREATE TABLE `a_bf_emblems` (
  `pid` bigint(255) NOT NULL,
  `emblem` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumpning av Data i tabell `a_bf_emblems`
--

INSERT INTO `a_bf_emblems` (`pid`, `emblem`) VALUES
(1, '2019070824123365001'),
(2, '2019070824123365011'),
(3, '2019070824123365001');

-- --------------------------------------------------------

--
-- Tabellstruktur `a_bf_gameservers`
--

CREATE TABLE `a_bf_gameservers` (
  `gid` bigint(255) NOT NULL DEFAULT '0',
  `mail` varchar(255) NOT NULL,
  `online` int(255) DEFAULT NULL,
  `mission` varchar(255) DEFAULT '',
  `difficulty` varchar(255) DEFAULT '',
  `bannerurl` varchar(255) DEFAULT '',
  `fairfight` varchar(255) DEFAULT '',
  `description1` varchar(255) DEFAULT '',
  `description2` varchar(255) DEFAULT '',
  `level` varchar(255) DEFAULT '',
  `levellocation` varchar(255) DEFAULT '',
  `mapsinfo` varchar(255) DEFAULT '',
  `message` varchar(255) DEFAULT '',
  `modd` varchar(255) DEFAULT '',
  `mode` varchar(255) DEFAULT '',
  `preset` varchar(255) DEFAULT '',
  `maps1` varchar(2000) DEFAULT '',
  `maps2` varchar(2000) DEFAULT '',
  `settings1` varchar(2000) DEFAULT '',
  `settings2` varchar(2000) DEFAULT '',
  `type` varchar(255) DEFAULT '',
  `gnam` varchar(255) DEFAULT '',
  `pcap` bigint(255) DEFAULT '0',
  `commanders` bigint(20) DEFAULT '0',
  `spectators` bigint(20) DEFAULT '0',
  `country` varchar(3) DEFAULT NULL,
  `region` varchar(255) DEFAULT '',
  `punkbuster` varchar(255) DEFAULT '',
  `servertype` varchar(255) DEFAULT '',
  `tickrate` int(10) DEFAULT '0',
  `tickratemax` int(10) DEFAULT '0',
  `last` bigint(255) DEFAULT NULL,
  `client_type` varchar(255) DEFAULT '',
  `ip_address` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumpning av Data i tabell `a_bf_gameservers`
--

INSERT INTO `a_bf_gameservers` (`gid`, `mail`, `online`, `mission`, `difficulty`, `bannerurl`, `fairfight`, `description1`, `description2`, `level`, `levellocation`, `mapsinfo`, `message`, `modd`, `mode`, `preset`, `maps1`, `maps2`, `settings1`, `settings2`, `type`, `gnam`, `pcap`, `commanders`, `spectators`, `country`, `region`, `punkbuster`, `servertype`, `tickrate`, `tickratemax`, `last`, `client_type`, `ip_address`) VALUES
(1, 'bf3_1', 0, '10', '10', '', '10', 'Server 1', '', 'MP_003', 'ConquestLarge0', '0,1;0,1', 'Welcome to Battlefield 3 Server 1', 'DEFAULT', 'ConquestLarge', 'NORMAL', 'MP_003,CQL0;MP_012,CQL0;MP_017,CQL0;', '', 'vbdm=100;vaba=true;vrhe=true;vnta=true;vpst=false;vtkk=0;osls=false;vprt=100;agjo=true;vtkc=10;vrtm=50;vvsd=30;vpmd=100;vvsa=true;vkca=true;vgmc=100;vnit=0;v3sp=true;vffi=false;vhud=true;v3ca=true;vshe=100;vmsp=true;vmin=true;', '', 'mp', 'Battlefield 3 Server 1', 64, 0, 0, 'SE', 'EU', 'NO', '10', 10, 10, 1712870602, 'bf3_server', '127.0.0.1'),
(2, 'bf3_3', 0, '10', '10', '', '10', 'Server 3', '', 'XP4_Quake', 'Scavenger0', '0,1;0,1', '', 'XPACK4', 'Scavenger', 'NORMAL', 'XP4_Quake,SCV0;XP4_Rubble,SCV0;XP4_Parl,SCV0;XP4_FD,SCV0;', '', 'vbdm=100;vaba=true;vrhe=true;vnta=true;vpst=false;vtkk=0;osls=false;vprt=100;agjo=true;vtkc=10;vrtm=50;vvsd=30;vpmd=100;vvsa=true;vkca=true;vgmc=100;vnit=0;v3sp=true;vffi=false;vhud=true;v3ca=true;vshe=100;vmsp=true;vmin=true;', '', 'mp', 'Battlefield 3 Server 3', 64, 0, 0, 'SE', 'EU', 'NO', '10', 10, 10, 1712693471, 'bf3_server', '127.0.0.1');

-- --------------------------------------------------------

--
-- Tabellstruktur `a_emu_achievements`
--

CREATE TABLE `a_emu_achievements` (
  `user_id` bigint(255) NOT NULL DEFAULT '0',
  `progress_id` varchar(255) DEFAULT '',
  `achievement_id` int(255) NOT NULL DEFAULT '0',
  `value` int(255) DEFAULT '0',
  `time` bigint(255) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellstruktur `a_emu_banned`
--

CREATE TABLE `a_emu_banned` (
  `mac` varchar(255) NOT NULL DEFAULT '',
  `dsnm` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `a_emu_friends`
--

CREATE TABLE `a_emu_friends` (
  `user_id` bigint(255) NOT NULL DEFAULT '0',
  `pid` bigint(255) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `dsnm` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `subscriber` varchar(255) NOT NULL,
  `subscribed` tinyint(1) NOT NULL,
  `time` bigint(255) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellstruktur `a_emu_loginpersona`
--

CREATE TABLE `a_emu_loginpersona` (
  `gid` int(255) NOT NULL,
  `mail` varchar(255) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `usermail` varchar(255) NOT NULL DEFAULT '',
  `local` tinyint(1) NOT NULL DEFAULT '0',
  `country` varchar(3) NOT NULL DEFAULT '',
  `client_type` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumpning av Data i tabell `a_emu_loginpersona`
--

INSERT INTO `a_emu_loginpersona` (`gid`, `mail`, `pass`, `usermail`, `local`, `country`, `client_type`) VALUES
(10000, 'bf3_1', 'password', '', 0, 'SE', ''),
(10001, 'bf3_2', 'password', '', 0, 'SE', ''),
(10002, 'bf3_3', 'password', '', 0, 'SE', ''),
(10003, 'bf3_4', 'password', '', 0, 'SE', ''),
(10004, 'bf4_1', 'password', '', 0, 'SE', ''),
(10005, 'bf4_2', 'password', '', 0, 'SE', ''),
(10006, 'bf4_3', 'password', '', 0, 'SE', ''),
(10007, 'bf4_4', 'password', '', 0, 'SE', ''),
(10012, 'bfh_1', 'password', '', 0, 'SE', ''),
(10013, 'bfh_2', 'password', '', 0, 'SE', ''),
(10014, 'bfh_3', 'password', '', 0, 'SE', ''),
(10015, 'bfh_4', 'password', '', 0, 'SE', '');

-- --------------------------------------------------------

--
-- Tabellstruktur `a_emu_playerinfo`
--

CREATE TABLE `a_emu_playerinfo` (
  `user_id` int(10) UNSIGNED ZEROFILL NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` text NOT NULL,
  `salt` varchar(100) NOT NULL,
  `email` varchar(120) DEFAULT NULL,
  `email_confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `AuthCode` char(255) DEFAULT NULL,
  `time` timestamp NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `dta` int(255) DEFAULT '0',
  `dtb` int(255) DEFAULT '0',
  `inGame` bigint(1) NOT NULL DEFAULT '0',
  `localPlayer` tinyint(1) DEFAULT '0',
  `dice_access` tinyint(1) DEFAULT '1',
  `online_access` tinyint(1) DEFAULT '0',
  `online_access2` tinyint(1) DEFAULT '0',
  `unlocked` int(1) DEFAULT '0',
  `loadstat` int(1) DEFAULT '0',
  `loadstatbf4` int(1) DEFAULT '0',
  `register_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `register_ip` varchar(15) NOT NULL,
  `login_ip` varchar(15) NOT NULL,
  `avatar` text,
  `coop_mission` varchar(255) NOT NULL,
  `coop_difficulty` varchar(255) NOT NULL,
  `devTeam` int(1) DEFAULT '0',
  `last_unixtime` bigint(255) DEFAULT '0',
  `country` varchar(255) DEFAULT '',
  `local` tinyint(1) DEFAULT '0',
  `gravToEmblem` int(1) NOT NULL DEFAULT '0',
  `sessionid` varchar(200) DEFAULT '',
  `user_key` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumpning av Data i tabell `a_emu_playerinfo`
--

INSERT INTO `a_emu_playerinfo` (`user_id`, `username`, `password`, `salt`, `email`, `email_confirmed`, `AuthCode`, `time`, `dta`, `dtb`, `inGame`, `localPlayer`, `dice_access`, `online_access`, `online_access2`, `unlocked`, `loadstat`, `loadstatbf4`, `register_date`, `register_ip`, `login_ip`, `avatar`, `coop_mission`, `coop_difficulty`, `devTeam`, `last_unixtime`, `country`, `local`, `gravToEmblem`, `sessionid`, `user_key`) VALUES
(0000000001, 'Chichimoker', 'bd303231dfa6a712d27e71ddf7442e60', '', 'ernestico833@gmail.com', 0, 'Chichimokerefdb702ee739bcde02d1c28aebee4717', '2024-04-11 21:21:52', 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, '2024-04-09 19:29:28', '169.254.74.83', '192.168.30.11', 'default-avatar-60.png', '', '', 0, 0, '', 0, 0, '', NULL),
(0000000002, 'ROMA0589', '2d5c92ea8249d0d1aa2f1692fb558a86', '', 'prietopuporamonleandro@gmail.com', 0, 'ROMA058966b76a98084dd84816c7560881585914', '2024-04-10 03:41:23', 0, 0, 0, 1, 1, 0, 0, 2, 0, 0, '2024-04-09 19:34:11', '169.254.207.137', '192.168.30.12', 'default-avatar-60.png', '', '', 0, 0, '', 0, 0, '', NULL),
(0000000003, 'Aotsuki', 'f43267215356a926a42ba05ad876a751', '', 'aotsukiasd0513@gmail.com', 0, 'Aotsuki0d2da18bf17d821ab2e8a8c879bd06cd', '2024-04-10 22:19:32', 0, 0, 0, 1, 1, 0, 0, 2, 0, 0, '2024-04-10 01:27:10', '192.168.30.13', '192.168.30.11', 'default-avatar-60.png', '', '', 0, 0, '', 0, 0, '', NULL);

-- --------------------------------------------------------

--
-- Tabellstruktur `a_emu_recentplayers`
--

CREATE TABLE `a_emu_recentplayers` (
  `pid` bigint(20) NOT NULL DEFAULT '0',
  `dsnm` varchar(20) NOT NULL DEFAULT '',
  `client_type` varchar(255) NOT NULL DEFAULT '',
  `last_unixtime` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumpning av Data i tabell `a_emu_recentplayers`
--

INSERT INTO `a_emu_recentplayers` (`pid`, `dsnm`, `client_type`, `last_unixtime`) VALUES
(1, 'Chichimoker', 'battlefield-3-pc', 1712870343),
(2, 'ROMA0589', 'battlefield-3-pc', 1712692933),
(3, 'Aotsuki', 'battlefield-3-pc', 1712712521);

-- --------------------------------------------------------

--
-- Tabellstruktur `a_emu_subnets`
--

CREATE TABLE `a_emu_subnets` (
  `Mask` varchar(30) NOT NULL DEFAULT '',
  `Map_ip` varchar(30) NOT NULL DEFAULT '',
  `Dst_ip` varchar(30) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumpning av Data i tabell `a_emu_subnets`
--

INSERT INTO `a_emu_subnets` (`Mask`, `Map_ip`, `Dst_ip`) VALUES
('0.0.0.0', '0.0.0.0', '0.0.0.0');

-- --------------------------------------------------------

--
-- Tabellstruktur `a_mohw_playerstats`
--

CREATE TABLE `a_mohw_playerstats` (
  `pid` int(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) NOT NULL DEFAULT '',
  `value` float(255,8) NOT NULL DEFAULT '0.00000000'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `a_mohw_playerstats2`
--

CREATE TABLE `a_mohw_playerstats2` (
  `pid` int(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) NOT NULL DEFAULT '',
  `value` float(255,8) NOT NULL DEFAULT '0.00000000'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `a_mohw_usersettings`
--

CREATE TABLE `a_mohw_usersettings` (
  `pid` bigint(255) NOT NULL DEFAULT '0',
  `key` varchar(767) NOT NULL DEFAULT '',
  `data` varchar(767) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bf3_playerstats`
--

CREATE TABLE `bf3_playerstats` (
  `pid` bigint(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) NOT NULL DEFAULT '',
  `value` float(255,8) NOT NULL DEFAULT '0.00000000'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumpning av Data i tabell `bf3_playerstats`
--

INSERT INTO `bf3_playerstats` (`pid`, `statname`, `value`) VALUES
(1, 'c_arM16__sfw_g', 54.00000000),
(1, 'c_arM16__sw_g', 34.13333511),
(1, 'c_asu__sa_g', 34.13333511),
(1, 'c_as__sa_g', 34.13333511),
(1, 'c_kany__sa_g', 34.13333511),
(1, 'c_m41_enu_rcu_suu_asu___sa_g', 34.13333511),
(1, 'c_m43_as__sa_g', 34.13333511),
(1, 'c_mp3__so_g', 34.13333511),
(1, 'c_mpl__so_g', 34.13333511),
(1, 'c_pM9__sfw_g', 1.00000000),
(1, 'c_wahAUS__sfw_g', 54.00000000),
(1, 'c_wahAUS__sw_g', 34.13333511),
(1, 'c_wahA__sfw_g', 54.00000000),
(1, 'c_wahA__sw_g', 34.13333511),
(1, 'c_waH__sfw_g', 55.00000000),
(1, 'c_waH__sw_g', 34.13333511),
(1, 'c_wA__sfw_g', 55.00000000),
(1, 'c_wA__sw_g', 34.13333511),
(1, 'c_whP__sfw_g', 1.00000000),
(1, 'c___sa_g', 34.13333511),
(1, 'c___sfw_g', 55.00000000),
(2, 'AAm_00', 1.00000000),
(2, 'AAm_01', 5943.83496094),
(2, 'ACH39_00', 1.00000000),
(2, 'ACH39_01', 5943.84814453),
(2, 'AHm_00', 1.00000000),
(2, 'AHm_01', 5943.83496094),
(2, 'c_AAm_bvaa__ghb_ghva', 1.00000000),
(2, 'c_ACH40___ru_ghva', 43.00000000),
(2, 'c_ahMi28__si_g', 5427.20507812),
(2, 'c_arAEK__kwa_g', 350.00000000),
(2, 'c_arAK74__kwa_g', 350.00000000),
(2, 'c_arAN94__kwa_g', 350.00000000),
(2, 'c_arAUG__kwa_g', 350.00000000),
(2, 'c_arF2__kwa_g', 350.00000000),
(2, 'c_arFAMAS__kwa_g', 350.00000000),
(2, 'c_arG3__kwa_g', 350.00000000),
(2, 'c_arKH__kwa_g', 350.00000000),
(2, 'c_arL85A2__kwa_g', 350.00000000),
(2, 'c_arM16__kwa_g', 350.00000000),
(2, 'c_arM16__sfw_g', 53.00000000),
(2, 'c_arM16__sw_g', 42.66666794),
(2, 'c_arM416__kwa_g', 350.00000000),
(2, 'c_arSCARL__kwa_g', 350.00000000),
(2, 'c_asu__sa_g', 42.66666794),
(2, 'c_as__sa_g', 42.66666794),
(2, 'c_caA91__kwa_g', 300.00000000),
(2, 'c_caACR__kwa_g', 350.00000000),
(2, 'c_caAKS__kwa_g', 300.00000000),
(2, 'c_caAKS__sfw_g', 69.00000000),
(2, 'c_caAKS__sw_g', 34.13333511),
(2, 'c_caG36__kwa_g', 350.00000000),
(2, 'c_caHK53__kwa_g', 300.00000000),
(2, 'c_caM4__kwa_g', 350.00000000),
(2, 'c_caMTAR21__kwa_g', 300.00000000),
(2, 'c_caQBZ95B__kwa_g', 270.00000000),
(2, 'c_caSCAR__kwa_g', 350.00000000),
(2, 'c_caSG553__kwa_g', 350.00000000),
(2, 'c_enr__sa_g', 42.66666794),
(2, 'c_en__sa_g', 42.66666794),
(2, 'c_fip__psx_g', 1.00000000),
(2, 'c_IFVm_bvifv__ghb_ghva', 1.00000000),
(2, 'c_JETm_bvjet__ghb_ghva', 1.00000000),
(2, 'c_kany__sa_g', 42.66666794),
(2, 'c_m41_enu_rcu_suu_asu___sa_g', 42.66666794),
(2, 'c_m42_enr_rcr_sur_asr___sa_g', 42.66666794),
(2, 'c_m43_as__sa_g', 42.66666794),
(2, 'c_m44_en__sa_g', 42.66666794),
(2, 'c_m47_vMBT__si_g', 1058.13269043),
(2, 'c_m48_vmaH__si_g', 5427.20507812),
(2, 'c_MARTm_bvart__ghb_ghva', 1.00000000),
(2, 'c_mbtM1A__si_g', 1058.13269043),
(2, 'c_MBTm_bvmbt__ghb_ghva', 1.00000000),
(2, 'c_mgL86A1__kwa_g', 350.00000000),
(2, 'c_mgLSAT__kwa_g', 200.00000000),
(2, 'c_mgM240__kwa_g', 235.00000000),
(2, 'c_mgM249__kwa_g', 235.00000000),
(2, 'c_mgM27__kwa_g', 350.00000000),
(2, 'c_mgM60__kwa_g', 235.00000000),
(2, 'c_mgMG36__kwa_g', 350.00000000),
(2, 'c_mgPech__kwa_g', 235.00000000),
(2, 'c_mgQBB95__kwa_g', 350.00000000),
(2, 'c_mgRPK__kwa_g', 350.00000000),
(2, 'c_mgT88__kwa_g', 235.00000000),
(2, 'c_mp12__so_g', 5469.87109375),
(2, 'c_mp3__so_g', 1100.79931641),
(2, 'c_mpl__so_g', 5469.85498047),
(2, 'c_mwin_mgc_roo_g', 1.00000000),
(2, 'c_mwin__roo_g', 1.00000000),
(2, 'c_SCTm_bvsh__ghb_ghva', 1.00000000),
(2, 'c_sg870__kwa_g', 350.00000000),
(2, 'c_sgDAO__kwa_g', 300.00000000),
(2, 'c_sgJackH__kwa_g', 350.00000000),
(2, 'c_sgM1014__kwa_g', 350.00000000),
(2, 'c_sgSaiga__kwa_g', 350.00000000),
(2, 'c_sgSPAS12__kwa_g', 350.00000000),
(2, 'c_sgUSAS__kwa_g', 350.00000000),
(2, 'c_smM5K__kwa_g', 175.00000000),
(2, 'c_smMP7__kwa_g', 150.00000000),
(2, 'c_smP90__kwa_g', 150.00000000),
(2, 'c_smPDR__kwa_g', 150.00000000),
(2, 'c_smPP19__kwa_g', 150.00000000),
(2, 'c_smPP2000__kwa_g', 150.00000000),
(2, 'c_smUMP__kwa_g', 150.00000000),
(2, 'c_smVAL__kwa_g', 200.00000000),
(2, 'c_srHK417__kwa_g', 270.00000000),
(2, 'c_srJNG90__kwa_g', 250.00000000),
(2, 'c_srL96__kwa_g', 270.00000000),
(2, 'c_srM39__kwa_g', 270.00000000),
(2, 'c_srM40__kwa_g', 270.00000000),
(2, 'c_srM98__kwa_g', 270.00000000),
(2, 'c_srMK11__kwa_g', 270.00000000),
(2, 'c_srQBU88__kwa_g', 270.00000000),
(2, 'c_srSKS__kwa_g', 300.00000000),
(2, 'c_srSV98__kwa_g', 270.00000000),
(2, 'c_srSVD__kwa_g', 270.00000000),
(2, 'c_ssclbas_bas__ghb_ghva', 1.00000000),
(2, 'c_ssclbe_be__ghb_ghva', 1.00000000),
(2, 'c_ssclbr_br__ghb_ghva', 1.00000000),
(2, 'c_ssclbsu_bsu__ghb_ghva', 1.00000000),
(2, 'c_ssclbvaa_bvaa__ghb_ghva', 1.00000000),
(2, 'c_ssclbvah_bvah__ghb_ghva', 1.00000000),
(2, 'c_ssclbvart_bvart__ghb_ghva', 1.00000000),
(2, 'c_ssclbvifv_bvifv__ghb_ghva', 1.00000000),
(2, 'c_ssclbvjet_bvjet__ghb_ghva', 1.00000000),
(2, 'c_ssclbvlbt_bvlbt__ghb_ghva', 1.00000000),
(2, 'c_ssclbvmbt_bvmbt__ghb_ghva', 1.00000000),
(2, 'c_ssclbvsh_bvsh__ghb_ghva', 1.00000000),
(2, 'c_sshaarAEK_arAEK__kwa_g', 350.00000000),
(2, 'c_sshaarAK74_arAK74__kwa_g', 350.00000000),
(2, 'c_sshaarAN94_arAN94__kwa_g', 350.00000000),
(2, 'c_sshaarAUG_arAUG__kwa_g', 350.00000000),
(2, 'c_sshaarF2_arF2__kwa_g', 350.00000000),
(2, 'c_sshaarFAMAS_arFAMAS__kwa_g', 350.00000000),
(2, 'c_sshaarG3_arG3__kwa_g', 350.00000000),
(2, 'c_sshaarKH_arKH__kwa_g', 350.00000000),
(2, 'c_sshaarL85A2_arL85A2__kwa_g', 350.00000000),
(2, 'c_sshaarM16_arM16__kwa_g', 350.00000000),
(2, 'c_sshaarM416_arM416__kwa_g', 350.00000000),
(2, 'c_sshaarSCARL_arSCARL__kwa_g', 350.00000000),
(2, 'c_sshacaA91_caA91__kwa_g', 300.00000000),
(2, 'c_sshacaACR_caACR__kwa_g', 350.00000000),
(2, 'c_sshacaAKS_caAKS__kwa_g', 300.00000000),
(2, 'c_sshacaG36_caG36__kwa_g', 350.00000000),
(2, 'c_sshacaHK53_caHK53__kwa_g', 300.00000000),
(2, 'c_sshacaM4_caM4__kwa_g', 350.00000000),
(2, 'c_sshacaMTAR21_caMTAR21__kwa_g', 300.00000000),
(2, 'c_sshacaQBZ95B_caQBZ95B__kwa_g', 270.00000000),
(2, 'c_sshacaSCAR_caSCAR__kwa_g', 350.00000000),
(2, 'c_sshacaSG553_caSG553__kwa_g', 350.00000000),
(2, 'c_sshamgL86A1_mgL86A1__kwa_g', 350.00000000),
(2, 'c_sshamgLSAT_mgLSAT__kwa_g', 200.00000000),
(2, 'c_sshamgM240_mgM240__kwa_g', 235.00000000),
(2, 'c_sshamgM249_mgM249__kwa_g', 235.00000000),
(2, 'c_sshamgM27_mgM27__kwa_g', 350.00000000),
(2, 'c_sshamgM60_mgM60__kwa_g', 235.00000000),
(2, 'c_sshamgMG36_mgMG36__kwa_g', 350.00000000),
(2, 'c_sshamgPech_mgPech__kwa_g', 235.00000000),
(2, 'c_sshamgQBB95_mgQBB95__kwa_g', 350.00000000),
(2, 'c_sshamgRPK_mgRPK__kwa_g', 350.00000000),
(2, 'c_sshamgT88_mgT88__kwa_g', 235.00000000),
(2, 'c_sshasg870_sg870__kwa_g', 350.00000000),
(2, 'c_sshasgDAO_sgDAO__kwa_g', 300.00000000),
(2, 'c_sshasgJackH_sgJackH__kwa_g', 350.00000000),
(2, 'c_sshasgM1014_sgM1014__kwa_g', 350.00000000),
(2, 'c_sshasgSaiga_sgSaiga__kwa_g', 350.00000000),
(2, 'c_sshasgSPAS12_sgSPAS12__kwa_g', 350.00000000),
(2, 'c_sshasgUSAS_sgUSAS__kwa_g', 350.00000000),
(2, 'c_sshasmM5K_smM5K__kwa_g', 175.00000000),
(2, 'c_sshasmMP7_smMP7__kwa_g', 150.00000000),
(2, 'c_sshasmP90_smP90__kwa_g', 150.00000000),
(2, 'c_sshasmPDR_smPDR__kwa_g', 150.00000000),
(2, 'c_sshasmPP19_smPP19__kwa_g', 150.00000000),
(2, 'c_sshasmPP2000_smPP2000__kwa_g', 150.00000000),
(2, 'c_sshasmUMP_smUMP__kwa_g', 150.00000000),
(2, 'c_sshasmVAL_smVAL__kwa_g', 200.00000000),
(2, 'c_sshasrHK417_srHK417__kwa_g', 270.00000000),
(2, 'c_sshasrJNG90_srJNG90__kwa_g', 250.00000000),
(2, 'c_sshasrL96_srL96__kwa_g', 270.00000000),
(2, 'c_sshasrM39_srM39__kwa_g', 270.00000000),
(2, 'c_sshasrM40_srM40__kwa_g', 270.00000000),
(2, 'c_sshasrM98_srM98__kwa_g', 270.00000000),
(2, 'c_sshasrMK11_srMK11__kwa_g', 270.00000000),
(2, 'c_sshasrQBU88_srQBU88__kwa_g', 270.00000000),
(2, 'c_sshasrSKS_srSKS__kwa_g', 300.00000000),
(2, 'c_sshasrSV98_srSV98__kwa_g', 270.00000000),
(2, 'c_sshasrSVD_srSVD__kwa_g', 270.00000000),
(2, 'c_TDm_bvlbt__ghb_ghva', 1.00000000),
(2, 'c_vAH__si_g', 5427.20507812),
(2, 'c_vA__si_g', 5427.18945312),
(2, 'c_vmaH__si_g', 5427.20507812),
(2, 'c_vmA__si_g', 5427.20507812),
(2, 'c_vMBT__si_g', 1058.13269043),
(2, 'c_vmL__si_g', 1058.13269043),
(2, 'c_vM__si_g', 5427.18945312),
(2, 'c_wahAUS__sfw_g', 53.00000000),
(2, 'c_wahAUS__sw_g', 42.66666794),
(2, 'c_wahA__sfw_g', 53.00000000),
(2, 'c_wahA__sw_g', 42.66666794),
(2, 'c_wahCRU__sfw_g', 69.00000000),
(2, 'c_wahCRU__sw_g', 34.13333511),
(2, 'c_wahC__sfw_g', 69.00000000),
(2, 'c_wahC__sw_g', 34.13333511),
(2, 'c_wahUGL__kwa_g', 20.00000000),
(2, 'c_wahUSG__kwa_g', 30.00000000),
(2, 'c_waH__sfw_g', 69.00000000),
(2, 'c_waH__sw_g', 34.13333511),
(2, 'c_wasRT__kwa_g', 1.00000000),
(2, 'c_wasRT__sfw_g', 42.00000000),
(2, 'c_wasRT__sw_g', 8.53333378),
(2, 'c_waS__sfw_g', 42.00000000),
(2, 'c_waS__sw_g', 8.53333378),
(2, 'c_wA__sfw_g', 111.00000000),
(2, 'c_wA__sw_g', 42.66666794),
(2, 'c_xp2ma01_wahA__kwa_g', 30.00000000),
(2, 'c_xp2ma01___sre_g', 10.00000000),
(2, 'c_xp2ma02_waeM67__kwa_g', 15.00000000),
(2, 'c_xp2ma02_wahU__kwa_g', 20.00000000),
(2, 'c_xp2ma03_wahM__kwa_g', 20.00000000),
(2, 'c_xp2ma03___sr_g', 20.00000000),
(2, 'c_xp2ma04_waeC4__kwa_g', 10.00000000),
(2, 'c_xp2ma04___dt_g', 10.00000000),
(2, 'c_xp2ma05_wahC__kwa_g', 30.00000000),
(2, 'c_xp2ma05_wahLAT__kwa_g', 20.00000000),
(2, 'c_xp2ma06_seqEOD__ki_g', 1.00000000),
(2, 'c_xp2ma06_wahC__kwa_g', 100.00000000),
(2, 'c_xp2ma07_seqUGS__spx_g', 10.00000000),
(2, 'c_xp2ma07___ccp_g', 25.00000000),
(2, 'c_xp2ma08_mwin_mgdom_roo_g', 3.00000000),
(2, 'c_xp2ma08_wahSR__kwa_g', 50.00000000),
(2, 'c_xp2ma09_wahSG__kwa_g', 20.00000000),
(2, 'c_xp2ma09_whP__kwa_g', 20.00000000),
(2, 'c_xp2ma10_t5_mggm_psy_g', 1.00000000),
(2, 'c_xp2ma10_wahSM__kwa_g', 100.00000000),
(2, 'c_xp2prema01_arF2__kwa_g', 50.00000000),
(2, 'c_xp2prema01__arF2_hsh_g', 25.00000000),
(2, 'c_xp2prema01___qh_g', 50.00000000),
(2, 'c_xp2prema02_mgPech__kwa_g', 50.00000000),
(2, 'c_xp2prema02___sr_g', 50.00000000),
(2, 'c_xp2prema03_seqRad__sv_g', 25.00000000),
(2, 'c_xp2prema03_srL96__kwa_g', 50.00000000),
(2, 'c_xp2prema03__srL96_hsh_g', 25.00000000),
(2, 'c_xp2prema04_caSCAR__kwa_g', 50.00000000),
(2, 'c_xp2prema04_wahSG__kwa_g', 25.00000000),
(2, 'c_xp2prema04___sqr_g', 50.00000000),
(2, 'c_xp2prema05_wahA__kwa_g', 30.00000000),
(2, 'c_xp2prema05_wahC__kwa_g', 30.00000000),
(2, 'c_xp2prema05_wahM__kwa_g', 30.00000000),
(2, 'c_xp2prema05_wahSR__kwa_g', 30.00000000),
(2, 'c_xp2prema05_whP__kwa_g', 15.00000000),
(2, 'c_xp2prema06_arF2__kwa_g', 100.00000000),
(2, 'c_xp2prema06_wahUSG__kwa_g', 25.00000000),
(2, 'c_xp2prema06___sre_g', 50.00000000),
(2, 'c_xp2prema07_mgPech__kwa_g', 100.00000000),
(2, 'c_xp2prema07_vA_waeC4_diw_g', 25.00000000),
(2, 'c_xp2prema07_waeClay__kwa_g', 25.00000000),
(2, 'c_xp2prema08_seqMAV__spx_g', 50.00000000),
(2, 'c_xp2prema08_srL96__hsd_ghvp', 350.00000000),
(2, 'c_xp2prema08_srL96__kwa_g', 100.00000000),
(2, 'c_xp2prema09_caSCAR__kwa_g', 100.00000000),
(2, 'c_xp2prema09_vmA_wahLAT_diw_g', 5.00000000),
(2, 'c_xp2prema09_waeMine__kwa_g', 20.00000000),
(2, 'c_xp2prema10_as__ks_g', 500.00000000),
(2, 'c_xp2prema10_en__ks_g', 400.00000000),
(2, 'c_xp2prema10_re__ks_g', 300.00000000),
(2, 'c_xp2prema10_su__ks_g', 400.00000000),
(2, 'c_xp3ma01_vMART__de_g', 1.00000000),
(2, 'c_xp3ma01_vTD__de_g', 10.00000000),
(2, 'c_xp3ma02_vTD__ki_g', 15.00000000),
(2, 'c_xp3ma03___r_g', 20.00000000),
(2, 'c_xp3ma04_vMART__ki_g', 10.00000000),
(2, 'c_xp3ma05_vmaG__ki_g', 15.00000000),
(2, 'c_xp3prema01_vMBT__ki_g', 50.00000000),
(2, 'c_xp3prema02_vIFV__ki_g', 50.00000000),
(2, 'c_xp3prema03_vmaH__ki_g', 50.00000000),
(2, 'c_xp3prema03_vMBT_vmaH_di_g', 25.00000000),
(2, 'c_xp3prema04_vmaH_vmaJ_di_g', 25.00000000),
(2, 'c_xp3prema04_vmaJ__ki_g', 50.00000000),
(2, 'c_xp3prema05_vmT__ki_g', 50.00000000),
(2, 'c_xp3prema05___sda_g', 50.00000000),
(2, 'c_xp3prema06_arL85A2__kwa_g', 100.00000000),
(2, 'c_xp3prema06_cr01__ga_g', 15.00000000),
(2, 'c_xp3prema06__arL85A2_hsh_g', 50.00000000),
(2, 'c_xp3prema07_caMTAR21__kwa_g', 100.00000000),
(2, 'c_xp3prema07_cr10__ga_g', 15.00000000),
(2, 'c_xp3prema07_vA_seqEOD_di_g', 10.00000000),
(2, 'c_xp3prema08_cr15__ga_g', 15.00000000),
(2, 'c_xp3prema08_mgLSAT__kwa_g', 100.00000000),
(2, 'c_xp3prema08_seqM224__ki_g', 25.00000000),
(2, 'c_xp3prema09_cr11__ga_g', 15.00000000),
(2, 'c_xp3prema09_srSKS__kwa_g', 100.00000000),
(2, 'c_xp3prema09___tad_g', 25.00000000),
(2, 'c_xp3prema10_smUMP_as_kwa_g', 50.00000000),
(2, 'c_xp3prema10_smUMP_en_kwa_g', 50.00000000),
(2, 'c_xp3prema10_smUMP_rc_kwa_g', 50.00000000),
(2, 'c_xp3prema10_smUMP_su_kwa_g', 50.00000000),
(2, 'c_xp4ma01_mwin_mgscv_roo_g', 3.00000000),
(2, 'c_xp4ma02_wasXB__kwa_g', 5.00000000),
(2, 'c_xp4ma03_wahA__kwa_g', 50.00000000),
(2, 'c_xp4ma03_wahC__kwa_g', 50.00000000),
(2, 'c_xp4ma04_wahA__hsd_g', 150.00000000),
(2, 'c_xp4ma04_wahC__hsd_g', 150.00000000),
(2, 'c_xp4ma04_wahSR__hsd_g', 150.00000000),
(2, 'c_xp4ma05___sp_g', 20.00000000),
(2, 'c_xp4ma05___tad_g', 10.00000000),
(2, 'c_xp4ma05___tx_g', 1.00000000),
(2, 'c_xp4ma06_wahSR__kwa_g', 50.00000000),
(2, 'c_xp4ma06__whP_hsh_g', 10.00000000),
(2, 'c_xp4ma07_waeC4__kwa_g', 5.00000000),
(2, 'c_xp4ma07_waeM67__kwa_g', 5.00000000),
(2, 'c_xp4ma07_wahUGL__kwa_g', 5.00000000),
(2, 'c_xp4ma08_trHmvM__ki_g', 5.00000000),
(2, 'c_xp4ma08_trVanM__ki_g', 5.00000000),
(2, 'c_xp4ma08_trVodnM__ki_g', 5.00000000),
(2, 'c_xp4ma09_wasXB__hsd_g', 150.00000000),
(2, 'c_xp4ma09_wasXB__kwa_g', 50.00000000),
(2, 'c_xp4ma10_XP4ACH02__m_g', 200.00000000),
(2, 'c_xp4ma10_xp4l1__so_g', 7200.00000000),
(2, 'c_xp4ma10_xp4l2__so_g', 7200.00000000),
(2, 'c_xp4ma10_xp4l3__so_g', 7200.00000000),
(2, 'c_xp4ma10_xp4l4__so_g', 7200.00000000),
(2, 'c_xp4prema01_arSCARL__kwa_g', 50.00000000),
(2, 'c_xp4prema01_caSCAR__kwa_g', 50.00000000),
(2, 'c_xp4prema01_wasK__kwa_g', 25.00000000),
(2, 'c_xp4prema02_seq_waeM67_diw_g', 20.00000000),
(2, 'c_xp4prema02_wahLAT__kwa_g', 50.00000000),
(2, 'c_xp4prema03___qh_g', 200.00000000),
(2, 'c_xp4prema03___sre_g', 100.00000000),
(2, 'c_xp4prema03___th_g', 200.00000000),
(2, 'c_xp4prema03___tre_g', 100.00000000),
(2, 'c_xp4prema04_cXP4PR1__ga_g', 1.00000000),
(2, 'c_xp4prema04_cXP4PR2__ga_g', 1.00000000),
(2, 'c_xp4prema04___mk_g', 5.00000000),
(2, 'c_xp4prema05_pMP443S__kwa_g', 50.00000000),
(2, 'c_xp4prema05_smVAL__kwa_g', 100.00000000),
(2, 'c_xp4prema06_arM416__kwa_g', 100.00000000),
(2, 'c_xp4prema06_cr44__ga_g', 15.00000000),
(2, 'c_xp4prema06___ak_g', 25.00000000),
(2, 'c_xp4prema07_caACR__kwa_g', 100.00000000),
(2, 'c_xp4prema07_cr02__ga_g', 15.00000000),
(2, 'c_xp4prema07_vA__ds_g', 50.00000000),
(2, 'c_xp4prema08_cr45__ga_g', 15.00000000),
(2, 'c_xp4prema08_seqUGS__spx_g', 50.00000000),
(2, 'c_xp4prema08_srJNG90__kwa_g', 100.00000000),
(2, 'c_xp4prema09_cr03__ga_g', 15.00000000),
(2, 'c_xp4prema09_mgM240__kwa_g', 100.00000000),
(2, 'c_xp4prema09___tr_g', 100.00000000),
(2, 'c_xp4prema10_smPP19_as_kwa_g', 50.00000000),
(2, 'c_xp4prema10_smPP19_en_kwa_g', 50.00000000),
(2, 'c_xp4prema10_smPP19_rc_kwa_g', 50.00000000),
(2, 'c_xp4prema10_smPP19_su_kwa_g', 50.00000000),
(2, 'c_xp5ma01_vmA_trXP5_di_g', 5.00000000),
(2, 'c_xp5ma02_mwin_mgctf_roo_g', 1.00000000),
(2, 'c_xp5ma02___fct_g', 2.00000000),
(2, 'c_xp5ma02___fr_g', 5.00000000),
(2, 'c_xp5ma03_vIFV__pdx_g', 1.00000000),
(2, 'c_xp5ma03_vmT__pdx_g', 1.00000000),
(2, 'c_xp5ma03___pdk_g', 1.00000000),
(2, 'c_xp5ma04_trKLR__rkv_g', 1.00000000),
(2, 'c_xp5ma04_vA__de_g', 20.00000000),
(2, 'c_xp5ma05__whP_hsh_g', 20.00000000),
(2, 'c_xp5prema01_srM39__kwa_g', 50.00000000),
(2, 'c_xp5prema01___fck_g', 10.00000000),
(2, 'c_xp5prema02_arSCARL__kwa_g', 100.00000000),
(2, 'c_xp5prema02___fct_g', 3.00000000),
(2, 'c_xp5prema03_caHK53__kwa_g', 50.00000000),
(2, 'c_xp5prema03_vA__de_g', 20.00000000),
(2, 'c_xp5prema04_mgQBB95__kwa_g', 100.00000000),
(2, 'c_xp5prema04___rs_g', 50.00000000),
(2, 'c_xp5prema05_sgJackH_as_kwa_g', 20.00000000),
(2, 'c_xp5prema05_sgJackH_en_kwa_g', 20.00000000),
(2, 'c_xp5prema05_sgJackH_rc_kwa_g', 20.00000000),
(2, 'c_xp5prema05_sgJackH_su_kwa_g', 20.00000000),
(2, 'c_xpma01___h_g', 10.00000000),
(2, 'c_xpma01___re_g', 10.00000000),
(2, 'c_xpma02_mwin_mgsd_roo_g', 5.00000000),
(2, 'c_xpma02_wahA__kwa_g', 100.00000000),
(2, 'c_xpma02_wahUGL__kwa_g', 20.00000000),
(2, 'c_xpma03_wasRT__kwa_g', 1.00000000),
(2, 'c_xpma03___r_g', 10.00000000),
(2, 'c_xpma04_mwin_mgc_roo_g', 6.00000000),
(2, 'c_xpma04_vA_wasRT_diw_g', 1.00000000),
(2, 'c_xpma04_wahLAT__kwa_g', 50.00000000),
(2, 'c_xpma05_seqM224__ki_g', 2.00000000),
(2, 'c_xpma05_wahM__kwa_g', 20.00000000),
(2, 'c_xpma06_wahM__kwa_g', 100.00000000),
(2, 'c_xpma06___rs_g', 50.00000000),
(2, 'c_xpma06___sua_g', 50.00000000),
(2, 'c_xpma07_wahSR__kwa_g', 20.00000000),
(2, 'c_xpma07___tx_g', 5.00000000),
(2, 'c_xpma08___dt_g', 5.00000000),
(2, 'c_xpma08___hsh_g', 50.00000000),
(2, 'c_xpma08___sp_g', 50.00000000),
(2, 'c_xpma09_xp11__so_g', 7200.00000000),
(2, 'c_xpma09___ca_g', 10.00000000),
(2, 'c_xpma09___ccp_g', 15.00000000),
(2, 'c_xpma10_ifvBTR90__ki_g', 10.00000000),
(2, 'c_xpma10_smPP19__kwa_g', 10.00000000),
(2, 'c_xpma10_trDpv__ki_g', 5.00000000),
(2, 'c_xpma10_xp12__so_g', 7200.00000000),
(2, 'c_xpma10_xp13__so_g', 7200.00000000),
(2, 'c___bc_g', 1.00000000),
(2, 'c___ccp_g', 5.00000000),
(2, 'c___ro_g', 1.00000000),
(2, 'c___sa_g', 6570.65429688),
(2, 'c___sfw_g', 355.00000000),
(2, 'elo_games', 1.00000000),
(2, 'IFVm_00', 1.00000000),
(2, 'IFVm_01', 5943.83496094),
(2, 'JETm_00', 1.00000000),
(2, 'JETm_01', 5943.83496094),
(2, 'MARTm_00', 1.00000000),
(2, 'MARTm_01', 5943.83496094),
(2, 'MBTm_00', 1.00000000),
(2, 'MBTm_01', 5943.83496094),
(2, 'r16_00', 1.00000000),
(2, 'r16_01', 5943.84814453),
(2, 'r19_00', 1.00000000),
(2, 'r19_01', 5943.84814453),
(2, 'r31_00', 1.00000000),
(2, 'r31_01', 5943.84814453),
(2, 'r36_00', 1.00000000),
(2, 'r36_01', 5943.84814453),
(2, 'r40_00', 1.00000000),
(2, 'r40_01', 5943.83837891),
(2, 'rank', 43.00000000),
(2, 'SCTm_00', 1.00000000),
(2, 'SCTm_01', 5943.83496094),
(2, 'sc_assault', 220000.00000000),
(2, 'sc_award', 121900.00000000),
(2, 'sc_engineer', 145000.00000000),
(2, 'sc_general', 1250.00000000),
(2, 'sc_recon', 195000.00000000),
(2, 'sc_support', 170000.00000000),
(2, 'sc_unlock', 211800.00000000),
(2, 'sc_vehicleaa', 32000.00000000),
(2, 'sc_vehicleah', 60250.00000000),
(2, 'sc_vehicleart', 9000.00000000),
(2, 'sc_vehicleifv', 90000.00000000),
(2, 'sc_vehiclejet', 35000.00000000),
(2, 'sc_vehiclelbt', 40000.00000000),
(2, 'sc_vehiclembt', 101000.00000000),
(2, 'sc_vehiclesh', 48000.00000000),
(2, 'ssclbas_00', 1.00000000),
(2, 'ssclbas_01', 5943.83496094),
(2, 'ssclbe_00', 1.00000000),
(2, 'ssclbe_01', 5943.83496094),
(2, 'ssclbr_00', 1.00000000),
(2, 'ssclbr_01', 5943.83496094),
(2, 'ssclbsu_00', 1.00000000),
(2, 'ssclbsu_01', 5943.83496094),
(2, 'ssclbvaa_00', 1.00000000),
(2, 'ssclbvaa_01', 5943.83496094),
(2, 'ssclbvah_00', 1.00000000),
(2, 'ssclbvah_01', 5943.83496094),
(2, 'ssclbvart_00', 1.00000000),
(2, 'ssclbvart_01', 5943.83496094),
(2, 'ssclbvifv_00', 1.00000000),
(2, 'ssclbvifv_01', 5943.83496094),
(2, 'ssclbvjet_00', 1.00000000),
(2, 'ssclbvjet_01', 5943.83496094),
(2, 'ssclbvlbt_00', 1.00000000),
(2, 'ssclbvlbt_01', 5943.83496094),
(2, 'ssclbvmbt_00', 1.00000000),
(2, 'ssclbvmbt_01', 5943.83496094),
(2, 'ssclbvsh_00', 1.00000000),
(2, 'ssclbvsh_01', 5943.83496094),
(2, 'sshaarAEK_00', 1.00000000),
(2, 'sshaarAEK_01', 5943.83496094),
(2, 'sshaarAK74_00', 1.00000000),
(2, 'sshaarAK74_01', 5943.83496094),
(2, 'sshaarAN94_00', 1.00000000),
(2, 'sshaarAN94_01', 5943.83496094),
(2, 'sshaarAUG_00', 1.00000000),
(2, 'sshaarAUG_01', 5943.83496094),
(2, 'sshaarF2_00', 1.00000000),
(2, 'sshaarF2_01', 5943.83496094),
(2, 'sshaarFAMAS_00', 1.00000000),
(2, 'sshaarFAMAS_01', 5943.83496094),
(2, 'sshaarG3_00', 1.00000000),
(2, 'sshaarG3_01', 5943.83496094),
(2, 'sshaarKH_00', 1.00000000),
(2, 'sshaarKH_01', 5943.83496094),
(2, 'sshaarL85A2_00', 1.00000000),
(2, 'sshaarL85A2_01', 5943.83496094),
(2, 'sshaarM16_00', 1.00000000),
(2, 'sshaarM16_01', 5943.83496094),
(2, 'sshaarM416_00', 1.00000000),
(2, 'sshaarM416_01', 5943.83496094),
(2, 'sshaarSCARL_00', 1.00000000),
(2, 'sshaarSCARL_01', 5943.83496094),
(2, 'sshacaA91_00', 1.00000000),
(2, 'sshacaA91_01', 5943.83496094),
(2, 'sshacaACR_00', 1.00000000),
(2, 'sshacaACR_01', 5943.83496094),
(2, 'sshacaAKS_00', 1.00000000),
(2, 'sshacaAKS_01', 5943.83496094),
(2, 'sshacaG36_00', 1.00000000),
(2, 'sshacaG36_01', 5943.83496094),
(2, 'sshacaHK53_00', 1.00000000),
(2, 'sshacaHK53_01', 5943.83496094),
(2, 'sshacaM4_00', 1.00000000),
(2, 'sshacaM4_01', 5943.83496094),
(2, 'sshacaMTAR21_00', 1.00000000),
(2, 'sshacaMTAR21_01', 5943.83496094),
(2, 'sshacaQBZ95B_00', 1.00000000),
(2, 'sshacaQBZ95B_01', 5943.83496094),
(2, 'sshacaSCAR_00', 1.00000000),
(2, 'sshacaSCAR_01', 5943.83496094),
(2, 'sshacaSG553_00', 1.00000000),
(2, 'sshacaSG553_01', 5943.83496094),
(2, 'sshamgL86A1_00', 1.00000000),
(2, 'sshamgL86A1_01', 5943.83496094),
(2, 'sshamgLSAT_00', 1.00000000),
(2, 'sshamgLSAT_01', 5943.83496094),
(2, 'sshamgM240_00', 1.00000000),
(2, 'sshamgM240_01', 5943.83496094),
(2, 'sshamgM249_00', 1.00000000),
(2, 'sshamgM249_01', 5943.83496094),
(2, 'sshamgM27_00', 1.00000000),
(2, 'sshamgM27_01', 5943.83496094),
(2, 'sshamgM60_00', 1.00000000),
(2, 'sshamgM60_01', 5943.83496094),
(2, 'sshamgMG36_00', 1.00000000),
(2, 'sshamgMG36_01', 5943.83496094),
(2, 'sshamgPech_00', 1.00000000),
(2, 'sshamgPech_01', 5943.83496094),
(2, 'sshamgQBB95_00', 1.00000000),
(2, 'sshamgQBB95_01', 5943.83496094),
(2, 'sshamgRPK_00', 1.00000000),
(2, 'sshamgRPK_01', 5943.83496094),
(2, 'sshamgT88_00', 1.00000000),
(2, 'sshamgT88_01', 5943.83496094),
(2, 'sshasg870_00', 1.00000000),
(2, 'sshasg870_01', 5943.83496094),
(2, 'sshasgDAO_00', 1.00000000),
(2, 'sshasgDAO_01', 5943.83496094),
(2, 'sshasgJackH_00', 1.00000000),
(2, 'sshasgJackH_01', 5943.83496094),
(2, 'sshasgM1014_00', 1.00000000),
(2, 'sshasgM1014_01', 5943.83496094),
(2, 'sshasgSaiga_00', 1.00000000),
(2, 'sshasgSaiga_01', 5943.83496094),
(2, 'sshasgSPAS12_00', 1.00000000),
(2, 'sshasgSPAS12_01', 5943.83496094),
(2, 'sshasgUSAS_00', 1.00000000),
(2, 'sshasgUSAS_01', 5943.83496094),
(2, 'sshasmM5K_00', 1.00000000),
(2, 'sshasmM5K_01', 5943.83496094),
(2, 'sshasmMP7_00', 1.00000000),
(2, 'sshasmMP7_01', 5943.83496094),
(2, 'sshasmP90_00', 1.00000000),
(2, 'sshasmP90_01', 5943.83496094),
(2, 'sshasmPDR_00', 1.00000000),
(2, 'sshasmPDR_01', 5943.83496094),
(2, 'sshasmPP19_00', 1.00000000),
(2, 'sshasmPP19_01', 5943.83496094),
(2, 'sshasmPP2000_00', 1.00000000),
(2, 'sshasmPP2000_01', 5943.83496094),
(2, 'sshasmUMP_00', 1.00000000),
(2, 'sshasmUMP_01', 5943.83496094),
(2, 'sshasmVAL_00', 1.00000000),
(2, 'sshasmVAL_01', 5943.83496094),
(2, 'sshasrHK417_00', 1.00000000),
(2, 'sshasrHK417_01', 5943.83496094),
(2, 'sshasrJNG90_00', 1.00000000),
(2, 'sshasrJNG90_01', 5943.83496094),
(2, 'sshasrL96_00', 1.00000000),
(2, 'sshasrL96_01', 5943.83496094),
(2, 'sshasrM39_00', 1.00000000),
(2, 'sshasrM39_01', 5943.83496094),
(2, 'sshasrM40_00', 1.00000000),
(2, 'sshasrM40_01', 5943.83496094),
(2, 'sshasrM98_00', 1.00000000),
(2, 'sshasrM98_01', 5943.83496094),
(2, 'sshasrMK11_00', 1.00000000),
(2, 'sshasrMK11_01', 5943.83496094),
(2, 'sshasrQBU88_00', 1.00000000),
(2, 'sshasrQBU88_01', 5943.83496094),
(2, 'sshasrSKS_00', 1.00000000),
(2, 'sshasrSKS_01', 5943.83496094),
(2, 'sshasrSV98_00', 1.00000000),
(2, 'sshasrSV98_01', 5943.83496094),
(2, 'sshasrSVD_00', 1.00000000),
(2, 'sshasrSVD_01', 5943.83496094),
(2, 'TDm_00', 1.00000000),
(2, 'TDm_01', 5943.83496094),
(2, 'xp2ma01_00', 1.00000000),
(2, 'xp2ma02_00', 1.00000000),
(2, 'xp2ma03_00', 1.00000000),
(2, 'xp2ma04_00', 1.00000000),
(2, 'xp2ma05_00', 1.00000000),
(2, 'xp2ma06_00', 1.00000000),
(2, 'xp2ma07_00', 1.00000000),
(2, 'xp2ma08_00', 1.00000000),
(2, 'xp2ma09_00', 1.00000000),
(2, 'xp2ma10_00', 1.00000000),
(2, 'xp2prema01_00', 1.00000000),
(2, 'xp2prema02_00', 1.00000000),
(2, 'xp2prema03_00', 1.00000000),
(2, 'xp2prema04_00', 1.00000000),
(2, 'xp2prema05_00', 1.00000000),
(2, 'xp2prema06_00', 1.00000000),
(2, 'xp2prema07_00', 1.00000000),
(2, 'xp2prema08_00', 1.00000000),
(2, 'xp2prema09_00', 1.00000000),
(2, 'xp2rgm_00', 1.00000000),
(2, 'xp3ma01_00', 1.00000000),
(2, 'xp3ma02_00', 1.00000000),
(2, 'xp3ma03_00', 1.00000000),
(2, 'xp3ma04_00', 1.00000000),
(2, 'xp3ma05_00', 1.00000000),
(2, 'xp3prema01_00', 1.00000000),
(2, 'xp3prema02_00', 1.00000000),
(2, 'xp3prema02_01', 5943.83496094),
(2, 'xp3prema03_00', 1.00000000),
(2, 'xp3prema03_01', 5943.83496094),
(2, 'xp3prema04_00', 1.00000000),
(2, 'xp3prema04_01', 5943.83496094),
(2, 'xp3prema05_00', 1.00000000),
(2, 'xp3prema05_01', 5943.83496094),
(2, 'xp3prema06_00', 1.00000000),
(2, 'xp3prema07_00', 1.00000000),
(2, 'xp3prema08_00', 1.00000000),
(2, 'xp3prema09_00', 1.00000000),
(2, 'xp3prema10_00', 1.00000000),
(2, 'xp3rnts_00', 1.00000000),
(2, 'xp4ma01_00', 1.00000000),
(2, 'xp4ma02_00', 1.00000000),
(2, 'xp4ma03_00', 1.00000000),
(2, 'xp4ma04_00', 1.00000000),
(2, 'xp4ma05_00', 1.00000000),
(2, 'xp4ma06_00', 1.00000000),
(2, 'xp4ma07_00', 1.00000000),
(2, 'xp4ma08_00', 1.00000000),
(2, 'xp4ma09_00', 1.00000000),
(2, 'xp4ma09_01', 5943.83496094),
(2, 'xp4ma10_00', 1.00000000),
(2, 'xp4prema01_00', 1.00000000),
(2, 'xp4prema02_00', 1.00000000),
(2, 'xp4prema03_00', 1.00000000),
(2, 'xp4prema04_00', 1.00000000),
(2, 'xp4prema05_00', 1.00000000),
(2, 'xp4prema06_00', 1.00000000),
(2, 'xp4prema07_00', 1.00000000),
(2, 'xp4prema08_00', 1.00000000),
(2, 'xp4prema09_00', 1.00000000),
(2, 'xp4prema10_00', 1.00000000),
(2, 'xp5ma01_00', 1.00000000),
(2, 'xp5ma02_00', 1.00000000),
(2, 'xp5ma03_00', 1.00000000),
(2, 'xp5ma04_00', 1.00000000),
(2, 'xp5ma05_00', 1.00000000),
(2, 'xp5ma05_01', 5943.83496094),
(2, 'xp5prema01_00', 1.00000000),
(2, 'xp5prema02_00', 1.00000000),
(2, 'xp5prema03_00', 1.00000000),
(2, 'xp5prema04_00', 1.00000000),
(2, 'xp5prema05_00', 1.00000000),
(2, 'xpma01_00', 1.00000000),
(2, 'xpma02_00', 1.00000000),
(2, 'xpma03_00', 1.00000000),
(2, 'xpma04_00', 1.00000000),
(2, 'xpma05_00', 1.00000000),
(2, 'xpma06_00', 1.00000000),
(2, 'xpma07_00', 1.00000000),
(2, 'xpma08_00', 1.00000000),
(2, 'xpma09_00', 1.00000000),
(2, 'xpma10_00', 1.00000000),
(3, 'AAm_00', 1.00000000),
(3, 'AAm_01', 5944.06201172),
(3, 'AHm_00', 1.00000000),
(3, 'AHm_01', 5944.06201172),
(3, 'c_AAm_bvaa__ghb_ghva', 1.00000000),
(3, 'c_ACH40___ru_ghva', 43.00000000),
(3, 'c_ahAH1Z__si_g', 238.93342590),
(3, 'c_arAEK__kwa_g', 350.00000000),
(3, 'c_arAK74__kwa_g', 350.00000000),
(3, 'c_arAN94__kwa_g', 350.00000000),
(3, 'c_arAUG__kwa_g', 350.00000000),
(3, 'c_arF2__kwa_g', 350.00000000),
(3, 'c_arFAMAS__kwa_g', 350.00000000),
(3, 'c_arG3__kwa_g', 350.00000000),
(3, 'c_arKH__kwa_g', 350.00000000),
(3, 'c_arL85A2__kwa_g', 350.00000000),
(3, 'c_arM16__kwa_g', 350.00000000),
(3, 'c_arM16__sw_g', 8.53333378),
(3, 'c_arM416__kwa_g', 350.00000000),
(3, 'c_arSCARL__kwa_g', 350.00000000),
(3, 'c_asu__sa_g', 8.53333378),
(3, 'c_as__sa_g', 8.53333378),
(3, 'c_caA91__kwa_g', 300.00000000),
(3, 'c_caACR__kwa_g', 350.00000000),
(3, 'c_caAKS__kwa_g', 300.00000000),
(3, 'c_caG36__kwa_g', 350.00000000),
(3, 'c_caHK53__kwa_g', 300.00000000),
(3, 'c_caM4__kwa_g', 350.00000000),
(3, 'c_caMTAR21__kwa_g', 300.00000000),
(3, 'c_caQBZ95B__kwa_g', 270.00000000),
(3, 'c_caSCAR__kwa_g', 350.00000000),
(3, 'c_caSG553__kwa_g', 350.00000000),
(3, 'c_IFVm_bvifv__ghb_ghva', 1.00000000),
(3, 'c_JETm_bvjet__ghb_ghva', 1.00000000),
(3, 'c_kany__sa_g', 8.53333378),
(3, 'c_m41_enu_rcu_suu_asu___sa_g', 8.53333378),
(3, 'c_m43_as__sa_g', 8.53333378),
(3, 'c_m48_vmaH__si_g', 238.93342590),
(3, 'c_MARTm_bvart__ghb_ghva', 1.00000000),
(3, 'c_MBTm_bvmbt__ghb_ghva', 1.00000000),
(3, 'c_mgL86A1__kwa_g', 350.00000000),
(3, 'c_mgLSAT__kwa_g', 200.00000000),
(3, 'c_mgM240__kwa_g', 235.00000000),
(3, 'c_mgM249__kwa_g', 235.00000000),
(3, 'c_mgM27__kwa_g', 350.00000000),
(3, 'c_mgM60__kwa_g', 235.00000000),
(3, 'c_mgMG36__kwa_g', 350.00000000),
(3, 'c_mgPech__kwa_g', 235.00000000),
(3, 'c_mgQBB95__kwa_g', 350.00000000),
(3, 'c_mgRPK__kwa_g', 350.00000000),
(3, 'c_mgT88__kwa_g', 235.00000000),
(3, 'c_mp12__so_g', 247.46676636),
(3, 'c_mpl__so_g', 247.46676636),
(3, 'c_SCTm_bvsh__ghb_ghva', 1.00000000),
(3, 'c_sg870__kwa_g', 350.00000000),
(3, 'c_sgDAO__kwa_g', 300.00000000),
(3, 'c_sgJackH__kwa_g', 350.00000000),
(3, 'c_sgM1014__kwa_g', 350.00000000),
(3, 'c_sgSaiga__kwa_g', 350.00000000),
(3, 'c_sgSPAS12__kwa_g', 350.00000000),
(3, 'c_sgUSAS__kwa_g', 350.00000000),
(3, 'c_smM5K__kwa_g', 175.00000000),
(3, 'c_smMP7__kwa_g', 150.00000000),
(3, 'c_smP90__kwa_g', 150.00000000),
(3, 'c_smPDR__kwa_g', 150.00000000),
(3, 'c_smPP19__kwa_g', 150.00000000),
(3, 'c_smPP2000__kwa_g', 150.00000000),
(3, 'c_smUMP__kwa_g', 150.00000000),
(3, 'c_smVAL__kwa_g', 200.00000000),
(3, 'c_srHK417__kwa_g', 270.00000000),
(3, 'c_srJNG90__kwa_g', 250.00000000),
(3, 'c_srL96__kwa_g', 270.00000000),
(3, 'c_srM39__kwa_g', 270.00000000),
(3, 'c_srM40__kwa_g', 270.00000000),
(3, 'c_srM98__kwa_g', 270.00000000),
(3, 'c_srMK11__kwa_g', 270.00000000),
(3, 'c_srQBU88__kwa_g', 270.00000000),
(3, 'c_srSKS__kwa_g', 300.00000000),
(3, 'c_srSV98__kwa_g', 270.00000000),
(3, 'c_srSVD__kwa_g', 270.00000000),
(3, 'c_ssclbas_bas__ghb_ghva', 1.00000000),
(3, 'c_ssclbe_be__ghb_ghva', 1.00000000),
(3, 'c_ssclbr_br__ghb_ghva', 1.00000000),
(3, 'c_ssclbsu_bsu__ghb_ghva', 1.00000000),
(3, 'c_ssclbvaa_bvaa__ghb_ghva', 1.00000000),
(3, 'c_ssclbvah_bvah__ghb_ghva', 1.00000000),
(3, 'c_ssclbvart_bvart__ghb_ghva', 1.00000000),
(3, 'c_ssclbvifv_bvifv__ghb_ghva', 1.00000000),
(3, 'c_ssclbvjet_bvjet__ghb_ghva', 1.00000000),
(3, 'c_ssclbvlbt_bvlbt__ghb_ghva', 1.00000000),
(3, 'c_ssclbvmbt_bvmbt__ghb_ghva', 1.00000000),
(3, 'c_ssclbvsh_bvsh__ghb_ghva', 1.00000000),
(3, 'c_sshaarAEK_arAEK__kwa_g', 350.00000000),
(3, 'c_sshaarAK74_arAK74__kwa_g', 350.00000000),
(3, 'c_sshaarAN94_arAN94__kwa_g', 350.00000000),
(3, 'c_sshaarAUG_arAUG__kwa_g', 350.00000000),
(3, 'c_sshaarF2_arF2__kwa_g', 350.00000000),
(3, 'c_sshaarFAMAS_arFAMAS__kwa_g', 350.00000000),
(3, 'c_sshaarG3_arG3__kwa_g', 350.00000000),
(3, 'c_sshaarKH_arKH__kwa_g', 350.00000000),
(3, 'c_sshaarL85A2_arL85A2__kwa_g', 350.00000000),
(3, 'c_sshaarM16_arM16__kwa_g', 350.00000000),
(3, 'c_sshaarM416_arM416__kwa_g', 350.00000000),
(3, 'c_sshaarSCARL_arSCARL__kwa_g', 350.00000000),
(3, 'c_sshacaA91_caA91__kwa_g', 300.00000000),
(3, 'c_sshacaACR_caACR__kwa_g', 350.00000000),
(3, 'c_sshacaAKS_caAKS__kwa_g', 300.00000000),
(3, 'c_sshacaG36_caG36__kwa_g', 350.00000000),
(3, 'c_sshacaHK53_caHK53__kwa_g', 300.00000000),
(3, 'c_sshacaM4_caM4__kwa_g', 350.00000000),
(3, 'c_sshacaMTAR21_caMTAR21__kwa_g', 300.00000000),
(3, 'c_sshacaQBZ95B_caQBZ95B__kwa_g', 270.00000000),
(3, 'c_sshacaSCAR_caSCAR__kwa_g', 350.00000000),
(3, 'c_sshacaSG553_caSG553__kwa_g', 350.00000000),
(3, 'c_sshamgL86A1_mgL86A1__kwa_g', 350.00000000),
(3, 'c_sshamgLSAT_mgLSAT__kwa_g', 200.00000000),
(3, 'c_sshamgM240_mgM240__kwa_g', 235.00000000),
(3, 'c_sshamgM249_mgM249__kwa_g', 235.00000000),
(3, 'c_sshamgM27_mgM27__kwa_g', 350.00000000),
(3, 'c_sshamgM60_mgM60__kwa_g', 235.00000000),
(3, 'c_sshamgMG36_mgMG36__kwa_g', 350.00000000),
(3, 'c_sshamgPech_mgPech__kwa_g', 235.00000000),
(3, 'c_sshamgQBB95_mgQBB95__kwa_g', 350.00000000),
(3, 'c_sshamgRPK_mgRPK__kwa_g', 350.00000000),
(3, 'c_sshamgT88_mgT88__kwa_g', 235.00000000),
(3, 'c_sshasg870_sg870__kwa_g', 350.00000000),
(3, 'c_sshasgDAO_sgDAO__kwa_g', 300.00000000),
(3, 'c_sshasgJackH_sgJackH__kwa_g', 350.00000000),
(3, 'c_sshasgM1014_sgM1014__kwa_g', 350.00000000),
(3, 'c_sshasgSaiga_sgSaiga__kwa_g', 350.00000000),
(3, 'c_sshasgSPAS12_sgSPAS12__kwa_g', 350.00000000),
(3, 'c_sshasgUSAS_sgUSAS__kwa_g', 350.00000000),
(3, 'c_sshasmM5K_smM5K__kwa_g', 175.00000000),
(3, 'c_sshasmMP7_smMP7__kwa_g', 150.00000000),
(3, 'c_sshasmP90_smP90__kwa_g', 150.00000000),
(3, 'c_sshasmPDR_smPDR__kwa_g', 150.00000000),
(3, 'c_sshasmPP19_smPP19__kwa_g', 150.00000000),
(3, 'c_sshasmPP2000_smPP2000__kwa_g', 150.00000000),
(3, 'c_sshasmUMP_smUMP__kwa_g', 150.00000000),
(3, 'c_sshasmVAL_smVAL__kwa_g', 200.00000000),
(3, 'c_sshasrHK417_srHK417__kwa_g', 270.00000000),
(3, 'c_sshasrJNG90_srJNG90__kwa_g', 250.00000000),
(3, 'c_sshasrL96_srL96__kwa_g', 270.00000000),
(3, 'c_sshasrM39_srM39__kwa_g', 270.00000000),
(3, 'c_sshasrM40_srM40__kwa_g', 270.00000000),
(3, 'c_sshasrM98_srM98__kwa_g', 270.00000000),
(3, 'c_sshasrMK11_srMK11__kwa_g', 270.00000000),
(3, 'c_sshasrQBU88_srQBU88__kwa_g', 270.00000000),
(3, 'c_sshasrSKS_srSKS__kwa_g', 300.00000000),
(3, 'c_sshasrSV98_srSV98__kwa_g', 270.00000000),
(3, 'c_sshasrSVD_srSVD__kwa_g', 270.00000000),
(3, 'c_TDm_bvlbt__ghb_ghva', 1.00000000),
(3, 'c_vAH__si_g', 238.93342590),
(3, 'c_vA__si_g', 238.93342590),
(3, 'c_vmaH__si_g', 238.93342590),
(3, 'c_vmA__si_g', 238.93342590),
(3, 'c_vM__si_g', 238.93342590),
(3, 'c_wahAUS__sw_g', 8.53333378),
(3, 'c_wahA__sw_g', 8.53333378),
(3, 'c_wahUGL__kwa_g', 20.00000000),
(3, 'c_wahUSG__kwa_g', 30.00000000),
(3, 'c_waH__sw_g', 8.53333378),
(3, 'c_wasRT__kwa_g', 1.00000000),
(3, 'c_wA__sw_g', 8.53333378),
(3, 'c_xp2ma01_wahA__kwa_g', 30.00000000),
(3, 'c_xp2ma01___sre_g', 10.00000000),
(3, 'c_xp2ma02_waeM67__kwa_g', 15.00000000),
(3, 'c_xp2ma02_wahU__kwa_g', 20.00000000),
(3, 'c_xp2ma03_wahM__kwa_g', 20.00000000),
(3, 'c_xp2ma03___sr_g', 20.00000000),
(3, 'c_xp2ma04_waeC4__kwa_g', 10.00000000),
(3, 'c_xp2ma04___dt_g', 10.00000000),
(3, 'c_xp2ma05_wahC__kwa_g', 30.00000000),
(3, 'c_xp2ma05_wahLAT__kwa_g', 20.00000000),
(3, 'c_xp2ma06_seqEOD__ki_g', 1.00000000),
(3, 'c_xp2ma06_wahC__kwa_g', 100.00000000),
(3, 'c_xp2ma07_seqUGS__spx_g', 10.00000000),
(3, 'c_xp2ma07___ccp_g', 20.00000000),
(3, 'c_xp2ma08_mwin_mgdom_roo_g', 3.00000000),
(3, 'c_xp2ma08_wahSR__kwa_g', 50.00000000),
(3, 'c_xp2ma09_wahSG__kwa_g', 20.00000000),
(3, 'c_xp2ma09_whP__kwa_g', 20.00000000),
(3, 'c_xp2ma10_t5_mggm_psy_g', 1.00000000),
(3, 'c_xp2ma10_wahSM__kwa_g', 100.00000000),
(3, 'c_xp2prema01_arF2__kwa_g', 50.00000000),
(3, 'c_xp2prema01__arF2_hsh_g', 25.00000000),
(3, 'c_xp2prema01___qh_g', 50.00000000),
(3, 'c_xp2prema02_mgPech__kwa_g', 50.00000000),
(3, 'c_xp2prema02___sr_g', 50.00000000),
(3, 'c_xp2prema03_seqRad__sv_g', 25.00000000),
(3, 'c_xp2prema03_srL96__kwa_g', 50.00000000),
(3, 'c_xp2prema03__srL96_hsh_g', 25.00000000),
(3, 'c_xp2prema04_caSCAR__kwa_g', 50.00000000),
(3, 'c_xp2prema04_wahSG__kwa_g', 25.00000000),
(3, 'c_xp2prema04___sqr_g', 50.00000000),
(3, 'c_xp2prema05_wahA__kwa_g', 30.00000000),
(3, 'c_xp2prema05_wahC__kwa_g', 30.00000000),
(3, 'c_xp2prema05_wahM__kwa_g', 30.00000000),
(3, 'c_xp2prema05_wahSR__kwa_g', 30.00000000),
(3, 'c_xp2prema05_whP__kwa_g', 15.00000000),
(3, 'c_xp2prema06_arF2__kwa_g', 100.00000000),
(3, 'c_xp2prema06_wahUSG__kwa_g', 25.00000000),
(3, 'c_xp2prema06___sre_g', 50.00000000),
(3, 'c_xp2prema07_mgPech__kwa_g', 100.00000000),
(3, 'c_xp2prema07_vA_waeC4_diw_g', 25.00000000),
(3, 'c_xp2prema07_waeClay__kwa_g', 25.00000000),
(3, 'c_xp2prema08_seqMAV__spx_g', 50.00000000),
(3, 'c_xp2prema08_srL96__hsd_ghvp', 350.00000000),
(3, 'c_xp2prema08_srL96__kwa_g', 100.00000000),
(3, 'c_xp2prema09_caSCAR__kwa_g', 100.00000000),
(3, 'c_xp2prema09_vmA_wahLAT_diw_g', 5.00000000),
(3, 'c_xp2prema09_waeMine__kwa_g', 20.00000000),
(3, 'c_xp2prema10_as__ks_g', 500.00000000),
(3, 'c_xp2prema10_en__ks_g', 400.00000000),
(3, 'c_xp2prema10_re__ks_g', 300.00000000),
(3, 'c_xp2prema10_su__ks_g', 400.00000000),
(3, 'c_xp3ma01_vMART__de_g', 1.00000000),
(3, 'c_xp3ma01_vTD__de_g', 10.00000000),
(3, 'c_xp3ma02_vTD__ki_g', 15.00000000),
(3, 'c_xp3ma03___r_g', 20.00000000),
(3, 'c_xp3ma04_vMART__ki_g', 10.00000000),
(3, 'c_xp3ma05_vmaG__ki_g', 15.00000000),
(3, 'c_xp3prema01_vMBT__ki_g', 50.00000000),
(3, 'c_xp3prema02_vIFV__ki_g', 50.00000000),
(3, 'c_xp3prema03_vmaH__ki_g', 50.00000000),
(3, 'c_xp3prema03_vMBT_vmaH_di_g', 25.00000000),
(3, 'c_xp3prema04_vmaH_vmaJ_di_g', 25.00000000),
(3, 'c_xp3prema04_vmaJ__ki_g', 50.00000000),
(3, 'c_xp3prema05_vmT__ki_g', 50.00000000),
(3, 'c_xp3prema05___sda_g', 50.00000000),
(3, 'c_xp3prema06_arL85A2__kwa_g', 100.00000000),
(3, 'c_xp3prema06_cr01__ga_g', 15.00000000),
(3, 'c_xp3prema06__arL85A2_hsh_g', 50.00000000),
(3, 'c_xp3prema07_caMTAR21__kwa_g', 100.00000000),
(3, 'c_xp3prema07_cr10__ga_g', 15.00000000),
(3, 'c_xp3prema07_vA_seqEOD_di_g', 10.00000000),
(3, 'c_xp3prema08_cr15__ga_g', 15.00000000),
(3, 'c_xp3prema08_mgLSAT__kwa_g', 100.00000000),
(3, 'c_xp3prema08_seqM224__ki_g', 25.00000000),
(3, 'c_xp3prema09_cr11__ga_g', 15.00000000),
(3, 'c_xp3prema09_srSKS__kwa_g', 100.00000000),
(3, 'c_xp3prema09___tad_g', 25.00000000),
(3, 'c_xp3prema10_smUMP_as_kwa_g', 50.00000000),
(3, 'c_xp3prema10_smUMP_en_kwa_g', 50.00000000),
(3, 'c_xp3prema10_smUMP_rc_kwa_g', 50.00000000),
(3, 'c_xp3prema10_smUMP_su_kwa_g', 50.00000000),
(3, 'c_xp4ma01_mwin_mgscv_roo_g', 3.00000000),
(3, 'c_xp4ma02_wasXB__kwa_g', 5.00000000),
(3, 'c_xp4ma03_wahA__kwa_g', 50.00000000),
(3, 'c_xp4ma03_wahC__kwa_g', 50.00000000),
(3, 'c_xp4ma04_wahA__hsd_g', 150.00000000),
(3, 'c_xp4ma04_wahC__hsd_g', 150.00000000),
(3, 'c_xp4ma04_wahSR__hsd_g', 150.00000000),
(3, 'c_xp4ma05___sp_g', 20.00000000),
(3, 'c_xp4ma05___tad_g', 10.00000000),
(3, 'c_xp4ma05___tx_g', 1.00000000),
(3, 'c_xp4ma06_wahSR__kwa_g', 50.00000000),
(3, 'c_xp4ma06__whP_hsh_g', 10.00000000),
(3, 'c_xp4ma07_waeC4__kwa_g', 5.00000000),
(3, 'c_xp4ma07_waeM67__kwa_g', 5.00000000),
(3, 'c_xp4ma07_wahUGL__kwa_g', 5.00000000),
(3, 'c_xp4ma08_trHmvM__ki_g', 5.00000000),
(3, 'c_xp4ma08_trVanM__ki_g', 5.00000000),
(3, 'c_xp4ma08_trVodnM__ki_g', 5.00000000),
(3, 'c_xp4ma09_wasXB__hsd_g', 150.00000000),
(3, 'c_xp4ma09_wasXB__kwa_g', 50.00000000),
(3, 'c_xp4ma10_XP4ACH02__m_g', 200.00000000),
(3, 'c_xp4ma10_xp4l1__so_g', 7200.00000000),
(3, 'c_xp4ma10_xp4l2__so_g', 7200.00000000),
(3, 'c_xp4ma10_xp4l3__so_g', 7200.00000000),
(3, 'c_xp4ma10_xp4l4__so_g', 7200.00000000),
(3, 'c_xp4prema01_arSCARL__kwa_g', 50.00000000),
(3, 'c_xp4prema01_caSCAR__kwa_g', 50.00000000),
(3, 'c_xp4prema01_wasK__kwa_g', 25.00000000),
(3, 'c_xp4prema02_seq_waeM67_diw_g', 20.00000000),
(3, 'c_xp4prema02_wahLAT__kwa_g', 50.00000000),
(3, 'c_xp4prema03___qh_g', 200.00000000),
(3, 'c_xp4prema03___sre_g', 100.00000000),
(3, 'c_xp4prema03___th_g', 200.00000000),
(3, 'c_xp4prema03___tre_g', 100.00000000),
(3, 'c_xp4prema04_cXP4PR1__ga_g', 1.00000000),
(3, 'c_xp4prema04_cXP4PR2__ga_g', 1.00000000),
(3, 'c_xp4prema04___mk_g', 5.00000000),
(3, 'c_xp4prema05_pMP443S__kwa_g', 50.00000000),
(3, 'c_xp4prema05_smVAL__kwa_g', 100.00000000),
(3, 'c_xp4prema06_arM416__kwa_g', 100.00000000),
(3, 'c_xp4prema06_cr44__ga_g', 15.00000000),
(3, 'c_xp4prema06___ak_g', 25.00000000),
(3, 'c_xp4prema07_caACR__kwa_g', 100.00000000),
(3, 'c_xp4prema07_cr02__ga_g', 15.00000000),
(3, 'c_xp4prema07_vA__ds_g', 50.00000000),
(3, 'c_xp4prema08_cr45__ga_g', 15.00000000),
(3, 'c_xp4prema08_seqUGS__spx_g', 50.00000000),
(3, 'c_xp4prema08_srJNG90__kwa_g', 100.00000000),
(3, 'c_xp4prema09_cr03__ga_g', 15.00000000),
(3, 'c_xp4prema09_mgM240__kwa_g', 100.00000000),
(3, 'c_xp4prema09___tr_g', 100.00000000),
(3, 'c_xp4prema10_smPP19_as_kwa_g', 50.00000000),
(3, 'c_xp4prema10_smPP19_en_kwa_g', 50.00000000),
(3, 'c_xp4prema10_smPP19_rc_kwa_g', 50.00000000),
(3, 'c_xp4prema10_smPP19_su_kwa_g', 50.00000000),
(3, 'c_xp5ma01_vmA_trXP5_di_g', 5.00000000),
(3, 'c_xp5ma02_mwin_mgctf_roo_g', 1.00000000),
(3, 'c_xp5ma02___fct_g', 2.00000000),
(3, 'c_xp5ma02___fr_g', 5.00000000),
(3, 'c_xp5ma03_vIFV__pdx_g', 1.00000000),
(3, 'c_xp5ma03_vmT__pdx_g', 1.00000000),
(3, 'c_xp5ma03___pdk_g', 1.00000000),
(3, 'c_xp5ma04_trKLR__rkv_g', 1.00000000),
(3, 'c_xp5ma04_vA__de_g', 20.00000000),
(3, 'c_xp5ma05__whP_hsh_g', 20.00000000),
(3, 'c_xp5prema01_srM39__kwa_g', 50.00000000),
(3, 'c_xp5prema01___fck_g', 10.00000000),
(3, 'c_xp5prema02_arSCARL__kwa_g', 100.00000000),
(3, 'c_xp5prema02___fct_g', 3.00000000),
(3, 'c_xp5prema03_caHK53__kwa_g', 50.00000000),
(3, 'c_xp5prema03_vA__de_g', 20.00000000),
(3, 'c_xp5prema04_mgQBB95__kwa_g', 100.00000000),
(3, 'c_xp5prema04___rs_g', 50.00000000),
(3, 'c_xp5prema05_sgJackH_as_kwa_g', 20.00000000),
(3, 'c_xp5prema05_sgJackH_en_kwa_g', 20.00000000),
(3, 'c_xp5prema05_sgJackH_rc_kwa_g', 20.00000000),
(3, 'c_xp5prema05_sgJackH_su_kwa_g', 20.00000000),
(3, 'c_xpma01___h_g', 10.00000000),
(3, 'c_xpma01___re_g', 10.00000000),
(3, 'c_xpma02_mwin_mgsd_roo_g', 5.00000000),
(3, 'c_xpma02_wahA__kwa_g', 100.00000000),
(3, 'c_xpma02_wahUGL__kwa_g', 20.00000000),
(3, 'c_xpma03_wasRT__kwa_g', 1.00000000),
(3, 'c_xpma03___r_g', 10.00000000),
(3, 'c_xpma04_mwin_mgc_roo_g', 5.00000000),
(3, 'c_xpma04_vA_wasRT_diw_g', 1.00000000),
(3, 'c_xpma04_wahLAT__kwa_g', 50.00000000),
(3, 'c_xpma05_seqM224__ki_g', 2.00000000),
(3, 'c_xpma05_wahM__kwa_g', 20.00000000),
(3, 'c_xpma06_wahM__kwa_g', 100.00000000),
(3, 'c_xpma06___rs_g', 50.00000000),
(3, 'c_xpma06___sua_g', 50.00000000),
(3, 'c_xpma07_wahSR__kwa_g', 20.00000000),
(3, 'c_xpma07___tx_g', 5.00000000),
(3, 'c_xpma08___dt_g', 5.00000000),
(3, 'c_xpma08___hsh_g', 50.00000000),
(3, 'c_xpma08___sp_g', 50.00000000),
(3, 'c_xpma09_xp11__so_g', 7200.00000000),
(3, 'c_xpma09___ca_g', 10.00000000),
(3, 'c_xpma09___ccp_g', 10.00000000),
(3, 'c_xpma10_ifvBTR90__ki_g', 10.00000000),
(3, 'c_xpma10_smPP19__kwa_g', 10.00000000),
(3, 'c_xpma10_trDpv__ki_g', 5.00000000),
(3, 'c_xpma10_xp12__so_g', 7200.00000000),
(3, 'c_xpma10_xp13__so_g', 7200.00000000),
(3, 'c___ro_g', 1.00000000),
(3, 'c___sa_g', 247.46676636),
(3, 'IFVm_00', 1.00000000),
(3, 'IFVm_01', 5944.06201172),
(3, 'JETm_00', 1.00000000),
(3, 'JETm_01', 5944.06201172),
(3, 'MARTm_00', 1.00000000),
(3, 'MARTm_01', 5944.06201172),
(3, 'MBTm_00', 1.00000000),
(3, 'MBTm_01', 5944.06201172),
(3, 'rank', 43.00000000),
(3, 'SCTm_00', 1.00000000),
(3, 'SCTm_01', 5944.06201172),
(3, 'sc_assault', 220000.00000000),
(3, 'sc_award', 120000.00000000),
(3, 'sc_engineer', 145000.00000000),
(3, 'sc_recon', 195000.00000000),
(3, 'sc_support', 170000.00000000),
(3, 'sc_unlock', 211800.00000000),
(3, 'sc_vehicleaa', 32000.00000000),
(3, 'sc_vehicleah', 60000.00000000),
(3, 'sc_vehicleart', 9000.00000000),
(3, 'sc_vehicleifv', 90000.00000000),
(3, 'sc_vehiclejet', 35000.00000000),
(3, 'sc_vehiclelbt', 40000.00000000),
(3, 'sc_vehiclembt', 100000.00000000),
(3, 'sc_vehiclesh', 48000.00000000),
(3, 'ssclbas_00', 1.00000000),
(3, 'ssclbas_01', 5944.06201172),
(3, 'ssclbe_00', 1.00000000),
(3, 'ssclbe_01', 5944.06201172),
(3, 'ssclbr_00', 1.00000000),
(3, 'ssclbr_01', 5944.06201172),
(3, 'ssclbsu_00', 1.00000000),
(3, 'ssclbsu_01', 5944.06201172),
(3, 'ssclbvaa_00', 1.00000000),
(3, 'ssclbvaa_01', 5944.06201172),
(3, 'ssclbvah_00', 1.00000000),
(3, 'ssclbvah_01', 5944.06201172),
(3, 'ssclbvart_00', 1.00000000),
(3, 'ssclbvart_01', 5944.06201172),
(3, 'ssclbvifv_00', 1.00000000),
(3, 'ssclbvifv_01', 5944.06201172),
(3, 'ssclbvjet_00', 1.00000000),
(3, 'ssclbvjet_01', 5944.06201172),
(3, 'ssclbvlbt_00', 1.00000000),
(3, 'ssclbvlbt_01', 5944.06201172),
(3, 'ssclbvmbt_00', 1.00000000),
(3, 'ssclbvmbt_01', 5944.06201172),
(3, 'ssclbvsh_00', 1.00000000),
(3, 'ssclbvsh_01', 5944.06201172),
(3, 'sshaarAEK_00', 1.00000000),
(3, 'sshaarAEK_01', 5944.06201172),
(3, 'sshaarAK74_00', 1.00000000),
(3, 'sshaarAK74_01', 5944.06201172),
(3, 'sshaarAN94_00', 1.00000000),
(3, 'sshaarAN94_01', 5944.06201172),
(3, 'sshaarAUG_00', 1.00000000),
(3, 'sshaarAUG_01', 5944.06201172),
(3, 'sshaarF2_00', 1.00000000),
(3, 'sshaarF2_01', 5944.06201172),
(3, 'sshaarFAMAS_00', 1.00000000),
(3, 'sshaarFAMAS_01', 5944.06201172),
(3, 'sshaarG3_00', 1.00000000),
(3, 'sshaarG3_01', 5944.06201172),
(3, 'sshaarKH_00', 1.00000000),
(3, 'sshaarKH_01', 5944.06201172),
(3, 'sshaarL85A2_00', 1.00000000),
(3, 'sshaarL85A2_01', 5944.06201172),
(3, 'sshaarM16_00', 1.00000000),
(3, 'sshaarM16_01', 5944.06201172),
(3, 'sshaarM416_00', 1.00000000),
(3, 'sshaarM416_01', 5944.06201172),
(3, 'sshaarSCARL_00', 1.00000000),
(3, 'sshaarSCARL_01', 5944.06201172),
(3, 'sshacaA91_00', 1.00000000),
(3, 'sshacaA91_01', 5944.06201172),
(3, 'sshacaACR_00', 1.00000000),
(3, 'sshacaACR_01', 5944.06201172),
(3, 'sshacaAKS_00', 1.00000000),
(3, 'sshacaAKS_01', 5944.06201172),
(3, 'sshacaG36_00', 1.00000000),
(3, 'sshacaG36_01', 5944.06201172),
(3, 'sshacaHK53_00', 1.00000000),
(3, 'sshacaHK53_01', 5944.06201172),
(3, 'sshacaM4_00', 1.00000000),
(3, 'sshacaM4_01', 5944.06201172),
(3, 'sshacaMTAR21_00', 1.00000000),
(3, 'sshacaMTAR21_01', 5944.06201172),
(3, 'sshacaQBZ95B_00', 1.00000000),
(3, 'sshacaQBZ95B_01', 5944.06201172),
(3, 'sshacaSCAR_00', 1.00000000),
(3, 'sshacaSCAR_01', 5944.06201172),
(3, 'sshacaSG553_00', 1.00000000),
(3, 'sshacaSG553_01', 5944.06201172),
(3, 'sshamgL86A1_00', 1.00000000),
(3, 'sshamgL86A1_01', 5944.06201172),
(3, 'sshamgLSAT_00', 1.00000000),
(3, 'sshamgLSAT_01', 5944.06201172),
(3, 'sshamgM240_00', 1.00000000),
(3, 'sshamgM240_01', 5944.06201172),
(3, 'sshamgM249_00', 1.00000000),
(3, 'sshamgM249_01', 5944.06201172),
(3, 'sshamgM27_00', 1.00000000),
(3, 'sshamgM27_01', 5944.06201172),
(3, 'sshamgM60_00', 1.00000000),
(3, 'sshamgM60_01', 5944.06201172),
(3, 'sshamgMG36_00', 1.00000000),
(3, 'sshamgMG36_01', 5944.06201172),
(3, 'sshamgPech_00', 1.00000000),
(3, 'sshamgPech_01', 5944.06201172),
(3, 'sshamgQBB95_00', 1.00000000),
(3, 'sshamgQBB95_01', 5944.06201172),
(3, 'sshamgRPK_00', 1.00000000),
(3, 'sshamgRPK_01', 5944.06201172),
(3, 'sshamgT88_00', 1.00000000),
(3, 'sshamgT88_01', 5944.06201172),
(3, 'sshasg870_00', 1.00000000),
(3, 'sshasg870_01', 5944.06201172),
(3, 'sshasgDAO_00', 1.00000000),
(3, 'sshasgDAO_01', 5944.06201172),
(3, 'sshasgJackH_00', 1.00000000),
(3, 'sshasgJackH_01', 5944.06201172),
(3, 'sshasgM1014_00', 1.00000000),
(3, 'sshasgM1014_01', 5944.06201172),
(3, 'sshasgSaiga_00', 1.00000000),
(3, 'sshasgSaiga_01', 5944.06201172),
(3, 'sshasgSPAS12_00', 1.00000000),
(3, 'sshasgSPAS12_01', 5944.06201172),
(3, 'sshasgUSAS_00', 1.00000000),
(3, 'sshasgUSAS_01', 5944.06201172),
(3, 'sshasmM5K_00', 1.00000000),
(3, 'sshasmM5K_01', 5944.06201172),
(3, 'sshasmMP7_00', 1.00000000),
(3, 'sshasmMP7_01', 5944.06201172),
(3, 'sshasmP90_00', 1.00000000),
(3, 'sshasmP90_01', 5944.06201172),
(3, 'sshasmPDR_00', 1.00000000),
(3, 'sshasmPDR_01', 5944.06201172),
(3, 'sshasmPP19_00', 1.00000000),
(3, 'sshasmPP19_01', 5944.06201172),
(3, 'sshasmPP2000_00', 1.00000000),
(3, 'sshasmPP2000_01', 5944.06201172),
(3, 'sshasmUMP_00', 1.00000000),
(3, 'sshasmUMP_01', 5944.06201172),
(3, 'sshasmVAL_00', 1.00000000),
(3, 'sshasmVAL_01', 5944.06201172),
(3, 'sshasrHK417_00', 1.00000000),
(3, 'sshasrHK417_01', 5944.06201172),
(3, 'sshasrJNG90_00', 1.00000000),
(3, 'sshasrJNG90_01', 5944.06201172),
(3, 'sshasrL96_00', 1.00000000),
(3, 'sshasrL96_01', 5944.06201172),
(3, 'sshasrM39_00', 1.00000000),
(3, 'sshasrM39_01', 5944.06201172),
(3, 'sshasrM40_00', 1.00000000),
(3, 'sshasrM40_01', 5944.06201172),
(3, 'sshasrM98_00', 1.00000000),
(3, 'sshasrM98_01', 5944.06201172),
(3, 'sshasrMK11_00', 1.00000000),
(3, 'sshasrMK11_01', 5944.06201172),
(3, 'sshasrQBU88_00', 1.00000000),
(3, 'sshasrQBU88_01', 5944.06201172),
(3, 'sshasrSKS_00', 1.00000000),
(3, 'sshasrSKS_01', 5944.06201172),
(3, 'sshasrSV98_00', 1.00000000),
(3, 'sshasrSV98_01', 5944.06201172),
(3, 'sshasrSVD_00', 1.00000000),
(3, 'sshasrSVD_01', 5944.06201172),
(3, 'TDm_00', 1.00000000),
(3, 'TDm_01', 5944.06201172),
(3, 'xp2ma01_00', 1.00000000),
(3, 'xp2ma02_00', 1.00000000),
(3, 'xp2ma03_00', 1.00000000),
(3, 'xp2ma04_00', 1.00000000),
(3, 'xp2ma05_00', 1.00000000),
(3, 'xp2ma06_00', 1.00000000),
(3, 'xp2ma07_00', 1.00000000),
(3, 'xp2ma08_00', 1.00000000),
(3, 'xp2ma09_00', 1.00000000),
(3, 'xp2ma10_00', 1.00000000),
(3, 'xp2prema01_00', 1.00000000),
(3, 'xp2prema02_00', 1.00000000),
(3, 'xp2prema03_00', 1.00000000),
(3, 'xp2prema04_00', 1.00000000),
(3, 'xp2prema05_00', 1.00000000),
(3, 'xp2prema06_00', 1.00000000),
(3, 'xp2prema07_00', 1.00000000),
(3, 'xp2prema08_00', 1.00000000),
(3, 'xp2prema09_00', 1.00000000),
(3, 'xp2rgm_00', 1.00000000),
(3, 'xp3ma01_00', 1.00000000),
(3, 'xp3ma02_00', 1.00000000),
(3, 'xp3ma03_00', 1.00000000),
(3, 'xp3ma04_00', 1.00000000),
(3, 'xp3ma05_00', 1.00000000),
(3, 'xp3prema01_00', 1.00000000),
(3, 'xp3prema02_00', 1.00000000),
(3, 'xp3prema02_01', 5944.06201172),
(3, 'xp3prema03_00', 1.00000000),
(3, 'xp3prema03_01', 5944.06201172),
(3, 'xp3prema04_00', 1.00000000),
(3, 'xp3prema04_01', 5944.06201172),
(3, 'xp3prema05_00', 1.00000000),
(3, 'xp3prema05_01', 5944.06201172),
(3, 'xp3prema06_00', 1.00000000),
(3, 'xp3prema07_00', 1.00000000),
(3, 'xp3prema08_00', 1.00000000),
(3, 'xp3prema09_00', 1.00000000),
(3, 'xp3prema10_00', 1.00000000),
(3, 'xp3rnts_00', 1.00000000),
(3, 'xp4ma01_00', 1.00000000),
(3, 'xp4ma02_00', 1.00000000),
(3, 'xp4ma03_00', 1.00000000),
(3, 'xp4ma04_00', 1.00000000),
(3, 'xp4ma05_00', 1.00000000),
(3, 'xp4ma06_00', 1.00000000),
(3, 'xp4ma07_00', 1.00000000),
(3, 'xp4ma08_00', 1.00000000),
(3, 'xp4ma09_00', 1.00000000),
(3, 'xp4ma09_01', 5944.06201172),
(3, 'xp4ma10_00', 1.00000000),
(3, 'xp4prema01_00', 1.00000000),
(3, 'xp4prema02_00', 1.00000000),
(3, 'xp4prema03_00', 1.00000000),
(3, 'xp4prema04_00', 1.00000000),
(3, 'xp4prema05_00', 1.00000000),
(3, 'xp4prema06_00', 1.00000000),
(3, 'xp4prema07_00', 1.00000000),
(3, 'xp4prema08_00', 1.00000000),
(3, 'xp4prema09_00', 1.00000000),
(3, 'xp4prema10_00', 1.00000000),
(3, 'xp5ma01_00', 1.00000000),
(3, 'xp5ma02_00', 1.00000000),
(3, 'xp5ma03_00', 1.00000000),
(3, 'xp5ma04_00', 1.00000000),
(3, 'xp5ma05_00', 1.00000000),
(3, 'xp5ma05_01', 5944.06201172),
(3, 'xp5prema01_00', 1.00000000),
(3, 'xp5prema02_00', 1.00000000),
(3, 'xp5prema03_00', 1.00000000),
(3, 'xp5prema04_00', 1.00000000),
(3, 'xp5prema05_00', 1.00000000),
(3, 'xpma01_00', 1.00000000),
(3, 'xpma02_00', 1.00000000),
(3, 'xpma03_00', 1.00000000),
(3, 'xpma04_00', 1.00000000),
(3, 'xpma05_00', 1.00000000),
(3, 'xpma06_00', 1.00000000),
(3, 'xpma07_00', 1.00000000),
(3, 'xpma08_00', 1.00000000),
(3, 'xpma09_00', 1.00000000),
(3, 'xpma10_00', 1.00000000);

-- --------------------------------------------------------

--
-- Tabellstruktur `bf3_playerstatsunlock`
--

CREATE TABLE `bf3_playerstatsunlock` (
  `pid` int(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `value` float(20,5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_roman_ci;

--
-- Dumpning av Data i tabell `bf3_playerstatsunlock`
--

INSERT INTO `bf3_playerstatsunlock` (`pid`, `statname`, `value`) VALUES
(99, 'c_arAEK__kwa_g', 350.00000),
(99, 'c_arAK74__kwa_g', 350.00000),
(99, 'c_arAN94__kwa_g', 350.00000),
(99, 'c_arAUG__kwa_g', 350.00000),
(99, 'c_arF2__kwa_g', 350.00000),
(99, 'c_arFAMAS__kwa_g', 350.00000),
(99, 'c_arG3__kwa_g', 350.00000),
(99, 'c_arKH__kwa_g', 350.00000),
(99, 'c_arL85A2__kwa_g', 350.00000),
(99, 'c_arM16__kwa_g', 350.00000),
(99, 'c_arM416__kwa_g', 350.00000),
(99, 'c_arSCARL__kwa_g', 350.00000),
(99, 'c_caA91__kwa_g', 300.00000),
(99, 'c_caACR__kwa_g', 350.00000),
(99, 'c_caAKS__kwa_g', 300.00000),
(99, 'c_caG36__kwa_g', 350.00000),
(99, 'c_caHK53__kwa_g', 300.00000),
(99, 'c_caM4__kwa_g', 350.00000),
(99, 'c_caMTAR21__kwa_g', 300.00000),
(99, 'c_caQBZ95B__kwa_g', 270.00000),
(99, 'c_caSCAR__kwa_g', 350.00000),
(99, 'c_caSG553__kwa_g', 350.00000),
(99, 'c_mgL86A1__kwa_g', 350.00000),
(99, 'c_mgLSAT__kwa_g', 200.00000),
(99, 'c_mgM240__kwa_g', 235.00000),
(99, 'c_mgM249__kwa_g', 235.00000),
(99, 'c_mgM27__kwa_g', 350.00000),
(99, 'c_mgM60__kwa_g', 235.00000),
(99, 'c_mgMG36__kwa_g', 350.00000),
(99, 'c_mgPech__kwa_g', 235.00000),
(99, 'c_mgQBB95__kwa_g', 350.00000),
(99, 'c_mgRPK__kwa_g', 350.00000),
(99, 'c_mgT88__kwa_g', 235.00000),
(99, 'c_sg870__kwa_g', 350.00000),
(99, 'c_sgDAO__kwa_g', 300.00000),
(99, 'c_sgJackH__kwa_g', 350.00000),
(99, 'c_sgM1014__kwa_g', 350.00000),
(99, 'c_sgSaiga__kwa_g', 350.00000),
(99, 'c_sgSPAS12__kwa_g', 350.00000),
(99, 'c_sgUSAS__kwa_g', 350.00000),
(99, 'c_smM5K__kwa_g', 175.00000),
(99, 'c_smMP7__kwa_g', 150.00000),
(99, 'c_smP90__kwa_g', 150.00000),
(99, 'c_smPDR__kwa_g', 150.00000),
(99, 'c_smPP19__kwa_g', 150.00000),
(99, 'c_smPP2000__kwa_g', 150.00000),
(99, 'c_smUMP__kwa_g', 150.00000),
(99, 'c_smVAL__kwa_g', 200.00000),
(99, 'c_srHK417__kwa_g', 270.00000),
(99, 'c_srJNG90__kwa_g', 250.00000),
(99, 'c_srL96__kwa_g', 270.00000),
(99, 'c_srM39__kwa_g', 270.00000),
(99, 'c_srM40__kwa_g', 270.00000),
(99, 'c_srM98__kwa_g', 270.00000),
(99, 'c_srMK11__kwa_g', 270.00000),
(99, 'c_srQBU88__kwa_g', 270.00000),
(99, 'c_srSKS__kwa_g', 300.00000),
(99, 'c_srSV98__kwa_g', 270.00000),
(99, 'c_srSVD__kwa_g', 270.00000),
(99, 'c_sshaarAEK_arAEK__kwa_g', 350.00000),
(99, 'c_sshaarAK74_arAK74__kwa_g', 350.00000),
(99, 'c_sshaarAN94_arAN94__kwa_g', 350.00000),
(99, 'c_sshaarAUG_arAUG__kwa_g', 350.00000),
(99, 'c_sshaarF2_arF2__kwa_g', 350.00000),
(99, 'c_sshaarFAMAS_arFAMAS__kwa_g', 350.00000),
(99, 'c_sshaarG3_arG3__kwa_g', 350.00000),
(99, 'c_sshaarKH_arKH__kwa_g', 350.00000),
(99, 'c_sshaarL85A2_arL85A2__kwa_g', 350.00000),
(99, 'c_sshaarM16_arM16__kwa_g', 350.00000),
(99, 'c_sshaarM416_arM416__kwa_g', 350.00000),
(99, 'c_sshaarSCARL_arSCARL__kwa_g', 350.00000),
(99, 'c_sshacaA91_caA91__kwa_g', 300.00000),
(99, 'c_sshacaACR_caACR__kwa_g', 350.00000),
(99, 'c_sshacaAKS_caAKS__kwa_g', 300.00000),
(99, 'c_sshacaG36_caG36__kwa_g', 350.00000),
(99, 'c_sshacaHK53_caHK53__kwa_g', 300.00000),
(99, 'c_sshacaM4_caM4__kwa_g', 350.00000),
(99, 'c_sshacaMTAR21_caMTAR21__kwa_g', 300.00000),
(99, 'c_sshacaQBZ95B_caQBZ95B__kwa_g', 270.00000),
(99, 'c_sshacaSCAR_caSCAR__kwa_g', 350.00000),
(99, 'c_sshacaSG553_caSG553__kwa_g', 350.00000),
(99, 'c_sshamgL86A1_mgL86A1__kwa_g', 350.00000),
(99, 'c_sshamgLSAT_mgLSAT__kwa_g', 200.00000),
(99, 'c_sshamgM240_mgM240__kwa_g', 235.00000),
(99, 'c_sshamgM249_mgM249__kwa_g', 235.00000),
(99, 'c_sshamgM27_mgM27__kwa_g', 350.00000),
(99, 'c_sshamgM60_mgM60__kwa_g', 235.00000),
(99, 'c_sshamgMG36_mgMG36__kwa_g', 350.00000),
(99, 'c_sshamgPech_mgPech__kwa_g', 235.00000),
(99, 'c_sshamgQBB95_mgQBB95__kwa_g', 350.00000),
(99, 'c_sshamgRPK_mgRPK__kwa_g', 350.00000),
(99, 'c_sshamgT88_mgT88__kwa_g', 235.00000),
(99, 'c_sshasg870_sg870__kwa_g', 350.00000),
(99, 'c_sshasgDAO_sgDAO__kwa_g', 300.00000),
(99, 'c_sshasgJackH_sgJackH__kwa_g', 350.00000),
(99, 'c_sshasgM1014_sgM1014__kwa_g', 350.00000),
(99, 'c_sshasgSaiga_sgSaiga__kwa_g', 350.00000),
(99, 'c_sshasgSPAS12_sgSPAS12__kwa_g', 350.00000),
(99, 'c_sshasgUSAS_sgUSAS__kwa_g', 350.00000),
(99, 'c_sshasmM5K_smM5K__kwa_g', 175.00000),
(99, 'c_sshasmMP7_smMP7__kwa_g', 150.00000),
(99, 'c_sshasmP90_smP90__kwa_g', 150.00000),
(99, 'c_sshasmPDR_smPDR__kwa_g', 150.00000),
(99, 'c_sshasmPP19_smPP19__kwa_g', 150.00000),
(99, 'c_sshasmPP2000_smPP2000__kwa_g', 150.00000),
(99, 'c_sshasmUMP_smUMP__kwa_g', 150.00000),
(99, 'c_sshasmVAL_smVAL__kwa_g', 200.00000),
(99, 'c_sshasrHK417_srHK417__kwa_g', 270.00000),
(99, 'c_sshasrJNG90_srJNG90__kwa_g', 250.00000),
(99, 'c_sshasrL96_srL96__kwa_g', 270.00000),
(99, 'c_sshasrM39_srM39__kwa_g', 270.00000),
(99, 'c_sshasrM40_srM40__kwa_g', 270.00000),
(99, 'c_sshasrM98_srM98__kwa_g', 270.00000),
(99, 'c_sshasrMK11_srMK11__kwa_g', 270.00000),
(99, 'c_sshasrQBU88_srQBU88__kwa_g', 270.00000),
(99, 'c_sshasrSKS_srSKS__kwa_g', 300.00000),
(99, 'c_sshasrSV98_srSV98__kwa_g', 270.00000),
(99, 'c_sshasrSVD_srSVD__kwa_g', 270.00000),
(99, 'c_wahUGL__kwa_g', 20.00000),
(99, 'c_wahUSG__kwa_g', 30.00000),
(99, 'c_wasRT__kwa_g', 1.00000),
(99, 'c_xp2ma01_wahA__kwa_g', 30.00000),
(99, 'c_xp2ma01___sre_g', 10.00000),
(99, 'c_xp2ma02_waeM67__kwa_g', 15.00000),
(99, 'c_xp2ma02_wahU__kwa_g', 20.00000),
(99, 'c_xp2ma03_wahM__kwa_g', 20.00000),
(99, 'c_xp2ma03___sr_g', 20.00000),
(99, 'c_xp2ma04_waeC4__kwa_g', 10.00000),
(99, 'c_xp2ma04___dt_g', 10.00000),
(99, 'c_xp2ma05_wahC__kwa_g', 30.00000),
(99, 'c_xp2ma05_wahLAT__kwa_g', 20.00000),
(99, 'c_xp2ma06_seqEOD__ki_g', 1.00000),
(99, 'c_xp2ma06_wahC__kwa_g', 100.00000),
(99, 'c_xp2ma07_seqUGS__spx_g', 10.00000),
(99, 'c_xp2ma07___ccp_g', 20.00000),
(99, 'c_xp2ma08_mwin_mgdom_roo_g', 3.00000),
(99, 'c_xp2ma08_wahSR__kwa_g', 50.00000),
(99, 'c_xp2ma09_wahSG__kwa_g', 20.00000),
(99, 'c_xp2ma09_whP__kwa_g', 20.00000),
(99, 'c_xp2ma10_t5_mggm_psy_g', 1.00000),
(99, 'c_xp2ma10_wahSM__kwa_g', 100.00000),
(99, 'c_xp2prema01_arF2__kwa_g', 50.00000),
(99, 'c_xp2prema01__arF2_hsh_g', 25.00000),
(99, 'c_xp2prema01___qh_g', 50.00000),
(99, 'c_xp2prema02_mgPech__kwa_g', 50.00000),
(99, 'c_xp2prema02___sr_g', 50.00000),
(99, 'c_xp2prema03_seqRad__sv_g', 25.00000),
(99, 'c_xp2prema03_srL96__kwa_g', 50.00000),
(99, 'c_xp2prema03__srL96_hsh_g', 25.00000),
(99, 'c_xp2prema04_caSCAR__kwa_g', 50.00000),
(99, 'c_xp2prema04_wahSG__kwa_g', 25.00000),
(99, 'c_xp2prema04___sqr_g', 50.00000),
(99, 'c_xp2prema05_wahA__kwa_g', 30.00000),
(99, 'c_xp2prema05_wahC__kwa_g', 30.00000),
(99, 'c_xp2prema05_wahM__kwa_g', 30.00000),
(99, 'c_xp2prema05_wahSR__kwa_g', 30.00000),
(99, 'c_xp2prema05_whP__kwa_g', 15.00000),
(99, 'c_xp2prema06_arF2__kwa_g', 100.00000),
(99, 'c_xp2prema06_wahUSG__kwa_g', 25.00000),
(99, 'c_xp2prema06___sre_g', 50.00000),
(99, 'c_xp2prema07_mgPech__kwa_g', 100.00000),
(99, 'c_xp2prema07_vA_waeC4_diw_g', 25.00000),
(99, 'c_xp2prema07_waeClay__kwa_g', 25.00000),
(99, 'c_xp2prema08_seqMAV__spx_g', 50.00000),
(99, 'c_xp2prema08_srL96__hsd_ghvp', 350.00000),
(99, 'c_xp2prema08_srL96__kwa_g', 100.00000),
(99, 'c_xp2prema09_caSCAR__kwa_g', 100.00000),
(99, 'c_xp2prema09_vmA_wahLAT_diw_g', 5.00000),
(99, 'c_xp2prema09_waeMine__kwa_g', 20.00000),
(99, 'c_xp2prema10_as__ks_g', 500.00000),
(99, 'c_xp2prema10_en__ks_g', 400.00000),
(99, 'c_xp2prema10_re__ks_g', 300.00000),
(99, 'c_xp2prema10_su__ks_g', 400.00000),
(99, 'c_xp3ma01_vMART__de_g', 1.00000),
(99, 'c_xp3ma01_vTD__de_g', 10.00000),
(99, 'c_xp3ma02_vTD__ki_g', 15.00000),
(99, 'c_xp3ma03___r_g', 20.00000),
(99, 'c_xp3ma04_vMART__ki_g', 10.00000),
(99, 'c_xp3ma05_vmaG__ki_g', 15.00000),
(99, 'c_xp3prema01_vMBT__ki_g', 50.00000),
(99, 'c_xp3prema02_vIFV__ki_g', 50.00000),
(99, 'c_xp3prema03_vmaH__ki_g', 50.00000),
(99, 'c_xp3prema03_vMBT_vmaH_di_g', 25.00000),
(99, 'c_xp3prema04_vmaH_vmaJ_di_g', 25.00000),
(99, 'c_xp3prema04_vmaJ__ki_g', 50.00000),
(99, 'c_xp3prema05_vmT__ki_g', 50.00000),
(99, 'c_xp3prema05___sda_g', 50.00000),
(99, 'c_xp3prema06_arL85A2__kwa_g', 100.00000),
(99, 'c_xp3prema06_cr01__ga_g', 15.00000),
(99, 'c_xp3prema06__arL85A2_hsh_g', 50.00000),
(99, 'c_xp3prema07_caMTAR21__kwa_g', 100.00000),
(99, 'c_xp3prema07_cr10__ga_g', 15.00000),
(99, 'c_xp3prema07_vA_seqEOD_di_g', 10.00000),
(99, 'c_xp3prema08_cr15__ga_g', 15.00000),
(99, 'c_xp3prema08_mgLSAT__kwa_g', 100.00000),
(99, 'c_xp3prema08_seqM224__ki_g', 25.00000),
(99, 'c_xp3prema09_cr11__ga_g', 15.00000),
(99, 'c_xp3prema09_srSKS__kwa_g', 100.00000),
(99, 'c_xp3prema09___tad_g', 25.00000),
(99, 'c_xp3prema10_smUMP_as_kwa_g', 50.00000),
(99, 'c_xp3prema10_smUMP_en_kwa_g', 50.00000),
(99, 'c_xp3prema10_smUMP_rc_kwa_g', 50.00000),
(99, 'c_xp3prema10_smUMP_su_kwa_g', 50.00000),
(99, 'c_xp4ma01_mwin_mgscv_roo_g', 3.00000),
(99, 'c_xp4ma02_wasXB__kwa_g', 5.00000),
(99, 'c_xp4ma03_wahA__kwa_g', 50.00000),
(99, 'c_xp4ma03_wahC__kwa_g', 50.00000),
(99, 'c_xp4ma04_wahA__hsd_g', 150.00000),
(99, 'c_xp4ma04_wahC__hsd_g', 150.00000),
(99, 'c_xp4ma04_wahSR__hsd_g', 150.00000),
(99, 'c_xp4ma05___sp_g', 20.00000),
(99, 'c_xp4ma05___tad_g', 10.00000),
(99, 'c_xp4ma05___tx_g', 1.00000),
(99, 'c_xp4ma06_wahSR__kwa_g', 50.00000),
(99, 'c_xp4ma06__whP_hsh_g', 10.00000),
(99, 'c_xp4ma07_waeC4__kwa_g', 5.00000),
(99, 'c_xp4ma07_waeM67__kwa_g', 5.00000),
(99, 'c_xp4ma07_wahUGL__kwa_g', 5.00000),
(99, 'c_xp4ma08_trHmvM__ki_g', 5.00000),
(99, 'c_xp4ma08_trVanM__ki_g', 5.00000),
(99, 'c_xp4ma08_trVodnM__ki_g', 5.00000),
(99, 'c_xp4ma09_wasXB__hsd_g', 150.00000),
(99, 'c_xp4ma09_wasXB__kwa_g', 50.00000),
(99, 'c_xp4ma10_XP4ACH02__m_g', 200.00000),
(99, 'c_xp4ma10_xp4l1__so_g', 7200.00000),
(99, 'c_xp4ma10_xp4l2__so_g', 7200.00000),
(99, 'c_xp4ma10_xp4l3__so_g', 7200.00000),
(99, 'c_xp4ma10_xp4l4__so_g', 7200.00000),
(99, 'c_xp4prema01_arSCARL__kwa_g', 50.00000),
(99, 'c_xp4prema01_caSCAR__kwa_g', 50.00000),
(99, 'c_xp4prema01_wasK__kwa_g', 25.00000),
(99, 'c_xp4prema02_seq_waeM67_diw_g', 20.00000),
(99, 'c_xp4prema02_wahLAT__kwa_g', 50.00000),
(99, 'c_xp4prema03___qh_g', 200.00000),
(99, 'c_xp4prema03___sre_g', 100.00000),
(99, 'c_xp4prema03___th_g', 200.00000),
(99, 'c_xp4prema03___tre_g', 100.00000),
(99, 'c_xp4prema04_cXP4PR1__ga_g', 1.00000),
(99, 'c_xp4prema04_cXP4PR2__ga_g', 1.00000),
(99, 'c_xp4prema04___mk_g', 5.00000),
(99, 'c_xp4prema05_pMP443S__kwa_g', 50.00000),
(99, 'c_xp4prema05_smVAL__kwa_g', 100.00000),
(99, 'c_xp4prema06_arM416__kwa_g', 100.00000),
(99, 'c_xp4prema06_cr44__ga_g', 15.00000),
(99, 'c_xp4prema06___ak_g', 25.00000),
(99, 'c_xp4prema07_caACR__kwa_g', 100.00000),
(99, 'c_xp4prema07_cr02__ga_g', 15.00000),
(99, 'c_xp4prema07_vA__ds_g', 50.00000),
(99, 'c_xp4prema08_cr45__ga_g', 15.00000),
(99, 'c_xp4prema08_seqUGS__spx_g', 50.00000),
(99, 'c_xp4prema08_srJNG90__kwa_g', 100.00000),
(99, 'c_xp4prema09_cr03__ga_g', 15.00000),
(99, 'c_xp4prema09_mgM240__kwa_g', 100.00000),
(99, 'c_xp4prema09___tr_g', 100.00000),
(99, 'c_xp4prema10_smPP19_as_kwa_g', 50.00000),
(99, 'c_xp4prema10_smPP19_en_kwa_g', 50.00000),
(99, 'c_xp4prema10_smPP19_rc_kwa_g', 50.00000),
(99, 'c_xp4prema10_smPP19_su_kwa_g', 50.00000),
(99, 'c_xp5ma01_vmA_trXP5_di_g', 5.00000),
(99, 'c_xp5ma02_mwin_mgctf_roo_g', 1.00000),
(99, 'c_xp5ma02___fct_g', 2.00000),
(99, 'c_xp5ma02___fr_g', 5.00000),
(99, 'c_xp5ma03_vIFV__pdx_g', 1.00000),
(99, 'c_xp5ma03_vmT__pdx_g', 1.00000),
(99, 'c_xp5ma03___pdk_g', 1.00000),
(99, 'c_xp5ma04_trKLR__rkv_g', 1.00000),
(99, 'c_xp5ma04_vA__de_g', 20.00000),
(99, 'c_xp5ma05__whP_hsh_g', 20.00000),
(99, 'c_xp5prema01_srM39__kwa_g', 50.00000),
(99, 'c_xp5prema01___fck_g', 10.00000),
(99, 'c_xp5prema02_arSCARL__kwa_g', 100.00000),
(99, 'c_xp5prema02___fct_g', 3.00000),
(99, 'c_xp5prema03_caHK53__kwa_g', 50.00000),
(99, 'c_xp5prema03_vA__de_g', 20.00000),
(99, 'c_xp5prema04_mgQBB95__kwa_g', 100.00000),
(99, 'c_xp5prema04___rs_g', 50.00000),
(99, 'c_xp5prema05_sgJackH_as_kwa_g', 20.00000),
(99, 'c_xp5prema05_sgJackH_en_kwa_g', 20.00000),
(99, 'c_xp5prema05_sgJackH_rc_kwa_g', 20.00000),
(99, 'c_xp5prema05_sgJackH_su_kwa_g', 20.00000),
(99, 'c_xpma01___h_g', 10.00000),
(99, 'c_xpma01___re_g', 10.00000),
(99, 'c_xpma02_mwin_mgsd_roo_g', 5.00000),
(99, 'c_xpma02_wahA__kwa_g', 100.00000),
(99, 'c_xpma02_wahUGL__kwa_g', 20.00000),
(99, 'c_xpma03_wasRT__kwa_g', 1.00000),
(99, 'c_xpma03___r_g', 10.00000),
(99, 'c_xpma04_mwin_mgc_roo_g', 5.00000),
(99, 'c_xpma04_vA_wasRT_diw_g', 1.00000),
(99, 'c_xpma04_wahLAT__kwa_g', 50.00000),
(99, 'c_xpma05_seqM224__ki_g', 2.00000),
(99, 'c_xpma05_wahM__kwa_g', 20.00000),
(99, 'c_xpma06_wahM__kwa_g', 100.00000),
(99, 'c_xpma06___rs_g', 50.00000),
(99, 'c_xpma06___sua_g', 50.00000),
(99, 'c_xpma07_wahSR__kwa_g', 20.00000),
(99, 'c_xpma07___tx_g', 5.00000),
(99, 'c_xpma08___dt_g', 5.00000),
(99, 'c_xpma08___hsh_g', 50.00000),
(99, 'c_xpma08___sp_g', 50.00000),
(99, 'c_xpma09_xp11__so_g', 7200.00000),
(99, 'c_xpma09___ca_g', 10.00000),
(99, 'c_xpma09___ccp_g', 10.00000),
(99, 'c_xpma10_ifvBTR90__ki_g', 10.00000),
(99, 'c_xpma10_smPP19__kwa_g', 10.00000),
(99, 'c_xpma10_trDpv__ki_g', 5.00000),
(99, 'c_xpma10_xp12__so_g', 7200.00000),
(99, 'c_xpma10_xp13__so_g', 7200.00000),
(99, 'sc_assault', 220000.00000),
(99, 'sc_engineer', 145000.00000),
(99, 'sc_recon', 195000.00000),
(99, 'sc_support', 170000.00000),
(99, 'sc_unlock', 211800.00000),
(99, 'sc_vehicleaa', 32000.00000),
(99, 'sc_vehicleah', 60000.00000),
(99, 'sc_vehicleart', 9000.00000),
(99, 'sc_vehicleifv', 90000.00000),
(99, 'sc_vehiclejet', 35000.00000),
(99, 'sc_vehiclelbt', 40000.00000),
(99, 'sc_vehiclembt', 100000.00000),
(99, 'sc_vehiclesh', 48000.00000),
(99, 'xp2ma01_00', 1.00000),
(99, 'xp2ma02_00', 1.00000),
(99, 'xp2ma03_00', 1.00000),
(99, 'xp2ma04_00', 1.00000),
(99, 'xp2ma05_00', 1.00000),
(99, 'xp2ma06_00', 1.00000),
(99, 'xp2ma07_00', 1.00000),
(99, 'xp2ma08_00', 1.00000),
(99, 'xp2ma09_00', 1.00000),
(99, 'xp2ma10_00', 1.00000),
(99, 'xp2prema01_00', 1.00000),
(99, 'xp2prema02_00', 1.00000),
(99, 'xp2prema03_00', 1.00000),
(99, 'xp2prema04_00', 1.00000),
(99, 'xp2prema05_00', 1.00000),
(99, 'xp2prema06_00', 1.00000),
(99, 'xp2prema07_00', 1.00000),
(99, 'xp2prema08_00', 1.00000),
(99, 'xp2prema09_00', 1.00000),
(99, 'xp2rgm_00', 1.00000),
(99, 'xp3ma01_00', 1.00000),
(99, 'xp3ma02_00', 1.00000),
(99, 'xp3ma03_00', 1.00000),
(99, 'xp3ma04_00', 1.00000),
(99, 'xp3ma05_00', 1.00000),
(99, 'xp3prema01_00', 1.00000),
(99, 'xp3prema06_00', 1.00000),
(99, 'xp3prema07_00', 1.00000),
(99, 'xp3prema08_00', 1.00000),
(99, 'xp3prema09_00', 1.00000),
(99, 'xp3prema10_00', 1.00000),
(99, 'xp3rnts_00', 1.00000),
(99, 'xp4ma01_00', 1.00000),
(99, 'xp4ma02_00', 1.00000),
(99, 'xp4ma03_00', 1.00000),
(99, 'xp4ma04_00', 1.00000),
(99, 'xp4ma05_00', 1.00000),
(99, 'xp4ma06_00', 1.00000),
(99, 'xp4ma07_00', 1.00000),
(99, 'xp4ma08_00', 1.00000),
(99, 'xp4ma10_00', 1.00000),
(99, 'xp4prema01_00', 1.00000),
(99, 'xp4prema02_00', 1.00000),
(99, 'xp4prema03_00', 1.00000),
(99, 'xp4prema04_00', 1.00000),
(99, 'xp4prema05_00', 1.00000),
(99, 'xp4prema06_00', 1.00000),
(99, 'xp4prema07_00', 1.00000),
(99, 'xp4prema08_00', 1.00000),
(99, 'xp4prema09_00', 1.00000),
(99, 'xp4prema10_00', 1.00000),
(99, 'xp5ma01_00', 1.00000),
(99, 'xp5ma02_00', 1.00000),
(99, 'xp5ma03_00', 1.00000),
(99, 'xp5ma04_00', 1.00000),
(99, 'xp5prema01_00', 1.00000),
(99, 'xp5prema02_00', 1.00000),
(99, 'xp5prema03_00', 1.00000),
(99, 'xp5prema04_00', 1.00000),
(99, 'xp5prema05_00', 1.00000),
(99, 'xpma01_00', 1.00000),
(99, 'xpma02_00', 1.00000),
(99, 'xpma03_00', 1.00000),
(99, 'xpma04_00', 1.00000),
(99, 'xpma05_00', 1.00000),
(99, 'xpma06_00', 1.00000),
(99, 'xpma07_00', 1.00000),
(99, 'xpma08_00', 1.00000),
(99, 'xpma09_00', 1.00000),
(99, 'xpma10_00', 1.00000);

-- --------------------------------------------------------

--
-- Tabellstruktur `bf3_playerstats_coop`
--

CREATE TABLE `bf3_playerstats_coop` (
  `pid` bigint(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) NOT NULL DEFAULT '',
  `value` float(255,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bf3_usersettings`
--

CREATE TABLE `bf3_usersettings` (
  `pid` bigint(255) NOT NULL DEFAULT '0',
  `key` varchar(3000) NOT NULL DEFAULT '',
  `data` varchar(6000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumpning av Data i tabell `bf3_usersettings`
--

INSERT INTO `bf3_usersettings` (`pid`, `key`, `data`) VALUES
(1, 'cust', 'AgAEKUyA9HdhJLQBAAYASAklFHdhJLQCAAIAKsxQ9HdhJLQAAgMA+ywPlKPH4Q8AAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALnJnp8PJr04ZZfHlyG+YMIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD0InecSAAAAAAAAAAAAAAAAAAAAAAi0/BEAAAAAAAAAAAAAAAAAAAAACXHRK6dwr6uDnFvyvAXZgouJe9gSPFxUAAAAAAAAAAAAAAAAAAAAABLy5ZEAAAAAAAAAAAAAAAAAAAAAFsY90i81EE2vQl71mkHarsDQoukaPJqI/jqYijj/WDPLk4mIi4l72B0XuvSAHcVDfsu2MavQ8vQS3KESIaIkFAAAAAAAAAAAAAAAAAAAAAAlJchxAAAAAAAAAAAAAAAAAAAAACWd85EAAAAAAAAAAAAAAAAAAAAAKUyA9N/1RUv3qJTzIKX9yBLcoRIqzFD0pjl+GxnsofG4jp29i4l72DKlZ1QAAAAAAAAAAAAAAAAAAAAAMseOkgAAAAAAAAAAAAAAAAAAAAA0nDsU8HEX4HQM+dG0bHLUi4l72DcnkpQAAAAAAAAAAAAAAAAAAAAAOQ4MFFQyo2P6n1vTEhyRlIuJe9hERa/UqY2pYINtobR4ZigCAAAAAEdrwrEAAAAAAAAAAAAAAAAAAAAASAklFGxjfLSJ5BAPeGYoAouJe9hIkCNUwcao6rJxp8s2jWPIi4l72EkXkrRBWykKg22htHhmKAIhvmDCTFlWtPajGJRf/CFzWSQ6SIuJe9hNeqiUgjwI6rzzB8vyssPIi4l72FWh9Gc6A4bqdvpk01gIRcuLiXvYXrUUcYdRsC95A4eWxj8PDok7Q6pfMrCSAAAAAAAAAAAAAAAAAAAAAGfj59Kn8ovs+a/aVSFC4W6LiXvYbkArEQAAAAAAAAAAAAAAAAAAAABueFvrAAAAAAAAAAAAAAAAAAAAAHVNdPQkN8GU8bwqc5fTo0iLiXvYdr2fsQAAAAAAAAAAAAAAAAAAAAB329aUAAAAAAAAAAAAAAAAAAAAAIR561QAAAAAAAAAAAAAAAAAAAAAiHu9VAAAAAAAAAAAAAAAAAAAAACOZO80AAAAAAAAAAAAAAAAAAAAAJLHUnEAAAAAAAAAAAAAAAAAAAAAk7ee1DoDhup2+mTTWAhFy4uJe9iVsSbSAAAAAAAAAAAAAAAAAAAAAJduIVQOUZPLoXN+kxehhncw/laSmVvD8gAAAAAAAAAAAAAAAAAAAACo+pvJylA/BZY4mSK8BdmCi4l72Kn709RY5oOROit9UzTAfn2LiXvYqsPftAAAAAAAAAAAAAAAAAAAAAC4no80KNip28B1CrE3wpeNi4l72L3UZlIAAAAAAAAAAAAAAAAAAAAAyIVelI9dguoJCOiPeGYoArXUgq/L4E3Xs3xfajorfVNeNDooi4l72Mvva/QAAAAAAAAAAAAAAAAAAAAA0IDAlAAAAAAAAAAAAAAAAAAAAADZu2yUiVoOioNtobR4ZigCi4l72OKaoZTILaARodJ8kwtPhHeLiXvY5+PUkgAAAAAAAAAAAAAAAAAAAADrRZARnttHdLiJ7/ZN9wDui4l72OvBkpRDc4t8sT5IkeNch12LiXvY85xh1J+DgnuNFntRqKyQQn31iL70SmeSaPcjteZfUxdny/3tEtyhEvn7i3QAAAAAAAAAAAAAAAAAAAAA+tjM+Ubn5hH9yqKTJ+Ko6IuJe9j7LA+UlE0BNA3O3NP7eqKCCWH+r7Zqe18='),
(1, 'cust', 'AgAEKUyA9HdhJLQBAAYASAklFHdhJLQCAAIAKsxQ9HdhJLQAAgMA+ywPlKPH4Q8AAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALnJnp8PJr04ZZfHlyG+YMIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD0InecSAAAAAAAAAAAAAAAAAAAAAAi0/BEAAAAAAAAAAAAAAAAAAAAACXHRK6dwr6uDnFvyvAXZgouJe9gSPFxUAAAAAAAAAAAAAAAAAAAAABLy5ZEAAAAAAAAAAAAAAAAAAAAAFsY90i81EE2vQl71mkHarsDQoukaPJqI/jqYijj/WDPLk4mIi4l72B0XuvSAHcVDfsu2MavQ8vQS3KESIaIkFAAAAAAAAAAAAAAAAAAAAAAlJchxAAAAAAAAAAAAAAAAAAAAACWd85EAAAAAAAAAAAAAAAAAAAAAKUyA9N/1RUv3qJTzIKX9yBLcoRIqzFD0pjl+GxnsofG4jp29i4l72DKlZ1QAAAAAAAAAAAAAAAAAAAAAMseOkgAAAAAAAAAAAAAAAAAAAAA0nDsU8HEX4HQM+dG0bHLUi4l72DcnkpQAAAAAAAAAAAAAAAAAAAAAOQ4MFFQyo2P6n1vTEhyRlIuJe9hERa/UqY2pYINtobR4ZigCAAAAAEdrwrEAAAAAAAAAAAAAAAAAAAAASAklFGxjfLSJ5BAPeGYoAouJe9hIkCNUwcao6rJxp8s2jWPIi4l72EkXkrRBWykKg22htHhmKAIhvmDCTFlWtPajGJRf/CFzWSQ6SIuJe9hNeqiUgjwI6rzzB8vyssPIi4l72FWh9Gc6A4bqdvpk01gIRcuLiXvYXrUUcYdRsC95A4eWxj8PDok7Q6pfMrCSAAAAAAAAAAAAAAAAAAAAAGfj59Kn8ovs+a/aVSFC4W6LiXvYbkArEQAAAAAAAAAAAAAAAAAAAABueFvrAAAAAAAAAAAAAAAAAAAAAHVNdPQkN8GU8bwqc5fTo0iLiXvYdr2fsQAAAAAAAAAAAAAAAAAAAAB329aUAAAAAAAAAAAAAAAAAAAAAIR561QAAAAAAAAAAAAAAAAAAAAAiHu9VAAAAAAAAAAAAAAAAAAAAACOZO80AAAAAAAAAAAAAAAAAAAAAJLHUnEAAAAAAAAAAAAAAAAAAAAAk7ee1DoDhup2+mTTWAhFy4uJe9iVsSbSAAAAAAAAAAAAAAAAAAAAAJduIVQOUZPLoXN+kxehhncw/laSmVvD8gAAAAAAAAAAAAAAAAAAAACo+pvJylA/BZY4mSK8BdmCi4l72Kn709RY5oOROit9UzTAfn2LiXvYqsPftAAAAAAAAAAAAAAAAAAAAAC4no80KNip28B1CrE3wpeNi4l72L3UZlIAAAAAAAAAAAAAAAAAAAAAyIVelI9dguoJCOiPeGYoArXUgq/L4E3Xs3xfajorfVNeNDooi4l72Mvva/QAAAAAAAAAAAAAAAAAAAAA0IDAlAAAAAAAAAAAAAAAAAAAAADZu2yUiVoOioNtobR4ZigCi4l72OKaoZTILaARodJ8kwtPhHeLiXvY5+PUkgAAAAAAAAAAAAAAAAAAAADrRZARnttHdLiJ7/ZN9wDui4l72OvBkpRDc4t8sT5IkeNch12LiXvY85xh1J+DgnuNFntRqKyQQn31iL70SmeSaPcjteZfUxdny/3tEtyhEvn7i3QAAAAAAAAAAAAAAAAAAAAA+tjM+Ubn5hH9yqKTJ+Ko6IuJe9j7LA+UlE0BNA3O3NP7eqKCCWH+r7Zqe18='),
(1, 'cust', 'AgAEKUyA9HdhJLQBAAYASAklFHdhJLQCAAIAKsxQ9HdhJLQAAgMA+ywPlKPH4Q8AAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALnJnp8PJr04ZZfHlyG+YMIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD0InecSAAAAAAAAAAAAAAAAAAAAAAi0/BEAAAAAAAAAAAAAAAAAAAAACXHRK6dwr6uDnFvyvAXZgouJe9gSPFxUAAAAAAAAAAAAAAAAAAAAABLy5ZEAAAAAAAAAAAAAAAAAAAAAFsY90i81EE2vQl71mkHarsDQoukaPJqI/jqYijj/WDPLk4mIi4l72B0XuvSAHcVDfsu2MavQ8vQS3KESIaIkFAAAAAAAAAAAAAAAAAAAAAAlJchxAAAAAAAAAAAAAAAAAAAAACWd85EAAAAAAAAAAAAAAAAAAAAAKUyA9N/1RUv3qJTzIKX9yBLcoRIqzFD0pjl+GxnsofG4jp29i4l72DKlZ1QAAAAAAAAAAAAAAAAAAAAAMseOkgAAAAAAAAAAAAAAAAAAAAA0nDsU8HEX4HQM+dG0bHLUi4l72DcnkpQAAAAAAAAAAAAAAAAAAAAAOQ4MFFQyo2P6n1vTEhyRlIuJe9hERa/UqY2pYINtobR4ZigCAAAAAEdrwrEAAAAAAAAAAAAAAAAAAAAASAklFGxjfLSJ5BAPeGYoAouJe9hIkCNUwcao6rJxp8s2jWPIi4l72EkXkrRBWykKg22htHhmKAIhvmDCTFlWtPajGJRf/CFzWSQ6SIuJe9hNeqiUgjwI6rzzB8vyssPIi4l72FWh9Gc6A4bqdvpk01gIRcuLiXvYXrUUcYdRsC95A4eWxj8PDok7Q6pfMrCSAAAAAAAAAAAAAAAAAAAAAGfj59Kn8ovs+a/aVSFC4W6LiXvYbkArEQAAAAAAAAAAAAAAAAAAAABueFvrAAAAAAAAAAAAAAAAAAAAAHVNdPQkN8GU8bwqc5fTo0iLiXvYdr2fsQAAAAAAAAAAAAAAAAAAAAB329aUAAAAAAAAAAAAAAAAAAAAAIR561QAAAAAAAAAAAAAAAAAAAAAiHu9VAAAAAAAAAAAAAAAAAAAAACOZO80AAAAAAAAAAAAAAAAAAAAAJLHUnEAAAAAAAAAAAAAAAAAAAAAk7ee1DoDhup2+mTTWAhFy4uJe9iVsSbSAAAAAAAAAAAAAAAAAAAAAJduIVQOUZPLoXN+kxehhncw/laSmVvD8gAAAAAAAAAAAAAAAAAAAACo+pvJylA/BZY4mSK8BdmCi4l72Kn709RY5oOROit9UzTAfn2LiXvYqsPftAAAAAAAAAAAAAAAAAAAAAC4no80KNip28B1CrE3wpeNi4l72L3UZlIAAAAAAAAAAAAAAAAAAAAAyIVelI9dguoJCOiPeGYoArXUgq/L4E3Xs3xfajorfVNeNDooi4l72Mvva/QAAAAAAAAAAAAAAAAAAAAA0IDAlAAAAAAAAAAAAAAAAAAAAADZu2yUiVoOioNtobR4ZigCi4l72OKaoZTILaARodJ8kwtPhHeLiXvY5+PUkgAAAAAAAAAAAAAAAAAAAADrRZARnttHdLiJ7/ZN9wDui4l72OvBkpRDc4t8sT5IkeNch12LiXvY85xh1J+DgnuNFntRqKyQQn31iL70SmeSaPcjteZfUxdny/3tEtyhEvn7i3QAAAAAAAAAAAAAAAAAAAAA+tjM+Ubn5hH9yqKTJ+Ko6IuJe9j7LA+UlE0BNA3O3NP7eqKCCWH+r7Zqe18=');

-- --------------------------------------------------------

--
-- Tabellstruktur `bf4_accessories`
--

CREATE TABLE `bf4_accessories` (
  `pid` bigint(255) NOT NULL,
  `name` char(255) NOT NULL,
  `type` int(10) NOT NULL,
  `opened` int(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bf4_battlepacks`
--

CREATE TABLE `bf4_battlepacks` (
  `bid` bigint(255) NOT NULL,
  `pid` bigint(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `type` int(255) NOT NULL,
  `tgen` int(255) NOT NULL,
  `opened` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bf4_boosts`
--

CREATE TABLE `bf4_boosts` (
  `pid` bigint(255) NOT NULL DEFAULT '0',
  `boost_25` int(255) NOT NULL DEFAULT '0',
  `acct_25` bigint(255) NOT NULL DEFAULT '0',
  `dura_25` int(255) NOT NULL DEFAULT '0',
  `boost_50` int(255) NOT NULL DEFAULT '0',
  `acct_50` bigint(255) NOT NULL DEFAULT '0',
  `dura_50` int(255) NOT NULL DEFAULT '0',
  `boost_100` int(255) NOT NULL DEFAULT '0',
  `acct_100` bigint(255) NOT NULL DEFAULT '0',
  `dura_100` int(255) NOT NULL DEFAULT '0',
  `boost_200` int(255) NOT NULL DEFAULT '0',
  `acct_200` bigint(255) NOT NULL DEFAULT '0',
  `dura_200` int(255) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bf4_messages`
--

CREATE TABLE `bf4_messages` (
  `message` varchar(255) NOT NULL,
  `time` varchar(255) NOT NULL DEFAULT '0',
  `ip` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bf4_playerstats`
--

CREATE TABLE `bf4_playerstats` (
  `pid` int(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) NOT NULL DEFAULT '',
  `value` float(255,8) NOT NULL DEFAULT '0.00000000'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bf4_usersettings`
--

CREATE TABLE `bf4_usersettings` (
  `pid` bigint(255) NOT NULL DEFAULT '0',
  `key` varchar(766) NOT NULL DEFAULT '',
  `data` varchar(766) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bfh_battlepacks`
--

CREATE TABLE `bfh_battlepacks` (
  `mPackId` bigint(255) NOT NULL,
  `mUserId` bigint(255) NOT NULL,
  `mPackKey` varchar(255) NOT NULL,
  `mDescriptionText` varchar(255) NOT NULL,
  `mPackIcon` varchar(255) NOT NULL,
  `mPurchasingComponentData` varchar(255) NOT NULL,
  `mQuantifiedItemList` varchar(255) NOT NULL,
  `mCategory` int(255) NOT NULL,
  `mTimeGenerated` bigint(255) NOT NULL,
  `mTimeCreated` bigint(255) NOT NULL,
  `mVisualName` varchar(255) NOT NULL,
  `opened` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellstruktur `bfh_boosts`
--

CREATE TABLE `bfh_boosts` (
  `uid` bigint(255) NOT NULL,
  `ckey` varchar(255) NOT NULL,
  `dura` int(255) NOT NULL,
  `actt` bigint(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellstruktur `bfh_playerstats`
--

CREATE TABLE `bfh_playerstats` (
  `pid` int(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) NOT NULL DEFAULT '',
  `value` float(255,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bfh_playerstats2`
--

CREATE TABLE `bfh_playerstats2` (
  `pid` int(255) NOT NULL DEFAULT '0',
  `statname` varchar(255) NOT NULL DEFAULT '',
  `value` float(255,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bfh_talliedconsumables`
--

CREATE TABLE `bfh_talliedconsumables` (
  `pid` bigint(255) NOT NULL,
  `ckey` varchar(255) NOT NULL,
  `qant` bigint(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellstruktur `bfh_unlocks`
--

CREATE TABLE `bfh_unlocks` (
  `pid` bigint(255) NOT NULL,
  `name` char(255) NOT NULL,
  `type` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `bfh_usersettings`
--

CREATE TABLE `bfh_usersettings` (
  `pid` bigint(255) NOT NULL DEFAULT '0',
  `key` varchar(767) NOT NULL DEFAULT '',
  `data` varchar(767) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `chatbox`
--

CREATE TABLE `chatbox` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(256) NOT NULL,
  `toname` varchar(256) NOT NULL,
  `message` text NOT NULL,
  `time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Tabellstruktur `rankdata`
--

CREATE TABLE `rankdata` (
  `rank` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `score` int(11) NOT NULL,
  `rankScore` int(11) NOT NULL,
  `unlocks` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumpning av Data i tabell `rankdata`
--

INSERT INTO `rankdata` (`rank`, `name`, `score`, `rankScore`, `unlocks`) VALUES
(0, 'Recruit', 0, 0, '-'),
(1, 'Private First Class', 1000, 1000, '870 MCS'),
(2, 'Private First Class 1 Star', 8000, 7000, 'Sprint'),
(3, 'Private First Class 2 Star', 18000, 10000, 'Woodland Camo'),
(4, 'Private First Class 3 Star', 29000, 11000, 'Glock 17'),
(5, 'Lance Corporal', 41000, 12000, 'Munition'),
(6, 'Lance Corporal 1 Star', 54000, 13000, 'Ranger Camo'),
(7, 'Lance Corporal 2 Star', 67000, 13000, 'PP-2000'),
(8, 'Lance Corporal 3 Star', 81000, 14000, 'Flak Jacket Specialization'),
(9, 'Corporal', 96000, 15000, 'Army Green Camo'),
(10, 'Corporal 1 Star', 111000, 15000, 'M9'),
(11, 'Corporal 2 Star', 130000, 19000, 'Explosives Specialization'),
(12, 'Corporal 3 Star', 150000, 20000, 'Expeditionary Force Camo'),
(13, 'Sergeant', 170000, 20000, 'MP443'),
(14, 'Sergeant 1 Star', 190000, 20000, 'Cover Specialization'),
(15, 'Sergeant 2 Star', 220000, 30000, 'Paratrooper Camo'),
(16, 'Sergeant 3 Star', 250000, 30000, 'UMP-45'),
(17, 'StaffSergeant', 280000, 30000, 'Suppressive Fire Specialization'),
(18, 'StaffSergeant 1 Star', 310000, 30000, 'Navy Blue Camo'),
(19, 'StaffSergeant 2 Star', 340000, 30000, 'Glock 17 Schallged?mpft'),
(20, 'Gunnery Sergeant', 370000, 30000, 'Frag Specialization'),
(21, 'Gunnery Sergeant 1 Star', 400000, 30000, 'Jungle Pattern Camo'),
(22, 'Gunnery Sergeant 2 Star', 430000, 30000, 'M1014?(M4 Benelli)'),
(23, 'Master Sergeant', 470000, 30000, 'Squad Sprint'),
(24, 'Master Sergeant1 Star', 510000, 30000, 'Desert Khaki Camo'),
(25, 'Master Sergeant2 Star', 550000, 40000, 'M9 Schallged?mpft'),
(26, 'First Sergeant', 590000, 40000, 'Squad Munition'),
(27, 'First Sergeant1 Star', 630000, 40000, 'Urban Pattern Camo'),
(28, 'First Sergeant2 Star', 670000, 40000, 'MP443 Schallged?mpft'),
(29, 'Master Gunnery Sergeant', 710000, 40000, 'Squad Flak'),
(30, 'Master Gunnery Sergeant 1 Star', 760000, 50000, 'Glock 18'),
(31, 'Master Gunnery Sergeant 2 Star', 810000, 50000, 'Squad Explosives'),
(32, 'Sergeant Major', 860000, 50000, 'PWD-R'),
(33, 'Sergeant Major 1 Star', 910000, 50000, 'Squad Supression'),
(34, 'Sergeant Major 2 Star', 960000, 50000, 'Saiga-12K'),
(35, 'Warrant Officer One', 1010000, 50000, 'Squad Cover'),
(36, 'Chief Warrant Officer Two', 1060000, 50000, '44er Magnum'),
(37, 'Chief Warrant Officer Three', 1110000, 50000, 'Squad Frag'),
(38, 'Chief Warrant Officer Four', 1165000, 55000, 'DAO-12'),
(39, 'Chief Warrant Officer Five', 1220000, 55000, 'Veteran Kit Camo'),
(40, 'Second Lieutenant', 1280000, 60000, 'FN P90'),
(41, 'First Lieutenant', 1340000, 60000, 'Glock 18 schallged?mpft'),
(42, 'Captain', 1400000, 60000, 'Spec Ops Black Camo'),
(43, 'Major', 1460000, 60000, 'USAS-12'),
(44, 'Lieutenant Colonel', 1520000, 60000, '44er mit Scope'),
(45, 'Colonel', 1600000, 80000, 'AS-VAL'),
(46, 'Colonel Service Star 1', 1830000, 230000, ''),
(47, 'Colonel Service Star 2', 2060000, 230000, ''),
(48, 'Colonel Service Star 3', 2290000, 230000, ''),
(49, 'Colonel Service Star 4', 2520000, 230000, ''),
(50, 'Colonel Service Star 5', 2750000, 230000, ''),
(51, 'Colonel Service Star 6', 2980000, 230000, ''),
(52, 'Colonel Service Star 7', 3210000, 230000, ''),
(53, 'Colonel Service Star 8', 3440000, 230000, ''),
(54, 'Colonel Service Star 9', 3670000, 230000, ''),
(55, 'Colonel Service Star 10', 3900000, 230000, ''),
(56, 'Colonel Service Star 11', 4130000, 230000, ''),
(57, 'Colonel Service Star 12', 4360000, 230000, ''),
(58, 'Colonel Service Star 13', 4590000, 230000, ''),
(59, 'Colonel Service Star 14', 4820000, 230000, ''),
(60, 'Colonel Service Star 15', 5050000, 230000, ''),
(61, 'Colonel Service Star 16', 5280000, 230000, ''),
(62, 'Colonel Service Star 17', 5510000, 230000, ''),
(63, 'Colonel Service Star 18', 5740000, 230000, ''),
(64, 'Colonel Service Star 19', 5970000, 230000, ''),
(65, 'Colonel Service Star 20', 6200000, 230000, ''),
(66, 'Colonel Service Star 21', 6430000, 230000, ''),
(67, 'Colonel Service Star 22', 6660000, 230000, ''),
(68, 'Colonel Service Star 23', 6890000, 230000, ''),
(69, 'Colonel Service Star 24', 7120000, 230000, ''),
(70, 'Colonel Service Star 25', 7350000, 230000, ''),
(71, 'Colonel Service Star 26', 7580000, 230000, ''),
(72, 'Colonel Service Star 27', 7810000, 230000, ''),
(73, 'Colonel Service Star 28', 8040000, 230000, ''),
(74, 'Colonel Service Star 29', 8270000, 230000, ''),
(75, 'Colonel Service Star 30', 8500000, 230000, ''),
(76, 'Colonel Service Star 31', 8730000, 230000, ''),
(77, 'Colonel Service Star 32', 8960000, 230000, ''),
(78, 'Colonel Service Star 33', 9190000, 230000, ''),
(79, 'Colonel Service Star 34', 9420000, 230000, ''),
(80, 'Colonel Service Star 35', 9650000, 230000, ''),
(81, 'Colonel Service Star 36', 9880000, 230000, ''),
(82, 'Colonel Service Star 37', 10110000, 230000, ''),
(83, 'Colonel Service Star 38', 10340000, 230000, ''),
(84, 'Colonel Service Star 39', 10570000, 230000, ''),
(85, 'Colonel Service Star 40', 10800000, 230000, ''),
(86, 'Colonel Service Star 41', 11030000, 230000, ''),
(87, 'Colonel Service Star 42', 11260000, 230000, ''),
(88, 'Colonel Service Star 43', 11490000, 230000, ''),
(89, 'Colonel Service Star 44', 11720000, 230000, ''),
(90, 'Colonel Service Star 45', 11950000, 230000, ''),
(91, 'Colonel Service Star 46', 12180000, 230000, ''),
(92, 'Colonel Service Star 47', 12410000, 230000, ''),
(93, 'Colonel Service Star 48', 12640000, 230000, ''),
(94, 'Colonel Service Star 49', 12870000, 230000, ''),
(95, 'Colonel Service Star 50', 13100000, 230000, ''),
(96, 'Colonel Service Star 51', 13330000, 230000, ''),
(97, 'Colonel Service Star 52', 13560000, 230000, ''),
(98, 'Colonel Service Star 53', 13790000, 230000, ''),
(99, 'Colonel Service Star 54', 14020000, 230000, ''),
(100, 'Colonel Service Star 55', 14250000, 230000, ''),
(101, 'Colonel Service Star 56', 14480000, 230000, ''),
(102, 'Colonel Service Star 57', 14710000, 230000, ''),
(103, 'Colonel Service Star 58', 14940000, 230000, ''),
(104, 'Colonel Service Star 59', 15170000, 230000, ''),
(105, 'Colonel Service Star 60', 15400000, 230000, ''),
(106, 'Colonel Service Star 61', 15630000, 230000, ''),
(107, 'Colonel Service Star 62', 15860000, 230000, ''),
(108, 'Colonel Service Star 63', 16090000, 230000, ''),
(109, 'Colonel Service Star 64', 16320000, 230000, ''),
(110, 'Colonel Service Star 65', 16550000, 230000, ''),
(111, 'Colonel Service Star 66', 16780000, 230000, ''),
(112, 'Colonel Service Star 67', 17010000, 230000, ''),
(113, 'Colonel Service Star 68', 17240000, 230000, ''),
(114, 'Colonel Service Star 69', 17470000, 230000, ''),
(115, 'Colonel Service Star 70', 17700000, 230000, ''),
(116, 'Colonel Service Star 71', 17930000, 230000, ''),
(117, 'Colonel Service Star 72', 18160000, 230000, ''),
(118, 'Colonel Service Star 73', 18390000, 230000, ''),
(119, 'Colonel Service Star 74', 18620000, 230000, ''),
(120, 'Colonel Service Star 75', 18850000, 230000, ''),
(121, 'Colonel Service Star 76', 19080000, 230000, ''),
(122, 'Colonel Service Star 77', 19310000, 230000, ''),
(123, 'Colonel Service Star 78', 19540000, 230000, ''),
(124, 'Colonel Service Star 79', 19770000, 230000, ''),
(125, 'Colonel Service Star 80', 20000000, 230000, ''),
(126, 'Colonel Service Star 81', 20230000, 230000, ''),
(127, 'Colonel Service Star 82', 20460000, 230000, ''),
(128, 'Colonel Service Star 83', 20690000, 230000, ''),
(129, 'Colonel Service Star 84', 20920000, 230000, ''),
(130, 'Colonel Service Star 85', 21150000, 230000, ''),
(131, 'Colonel Service Star 86', 21380000, 230000, ''),
(132, 'Colonel Service Star 87', 21610000, 230000, ''),
(133, 'Colonel Service Star 88', 21840000, 230000, ''),
(134, 'Colonel Service Star 89', 22070000, 230000, ''),
(135, 'Colonel Service Star 90', 22300000, 230000, ''),
(136, 'Colonel Service Star 91', 22530000, 230000, ''),
(137, 'Colonel Service Star 92', 22760000, 230000, ''),
(138, 'Colonel Service Star 93', 22990000, 230000, ''),
(139, 'Colonel Service Star 94', 23220000, 230000, ''),
(140, 'Colonel Service Star 95', 23450000, 230000, ''),
(141, 'Colonel Service Star 96', 23680000, 230000, ''),
(142, 'Colonel Service Star 97', 23910000, 230000, ''),
(143, 'Colonel Service Star 98', 24140000, 230000, ''),
(144, 'Colonel Service Star 99', 24370000, 230000, ''),
(145, 'Colonel Service Star 100', 24600000, 230000, '');

-- --------------------------------------------------------

--
-- Tabellstruktur `rankmatrix`
--

CREATE TABLE `rankmatrix` (
  `rank` int(11) NOT NULL,
  `score` float(20,5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_roman_ci;

--
-- Dumpning av Data i tabell `rankmatrix`
--

INSERT INTO `rankmatrix` (`rank`, `score`) VALUES
(0, 0.00000),
(1, 1000.00000),
(2, 8000.00000),
(3, 18000.00000),
(4, 29000.00000),
(5, 41000.00000),
(6, 54000.00000),
(7, 67000.00000),
(8, 81000.00000),
(9, 96000.00000),
(10, 111000.00000),
(11, 130000.00000),
(12, 150000.00000),
(13, 170000.00000),
(14, 190000.00000),
(15, 220000.00000),
(16, 250000.00000),
(17, 280000.00000),
(18, 310000.00000),
(19, 340000.00000),
(20, 370000.00000),
(21, 400000.00000),
(22, 430000.00000),
(23, 470000.00000),
(24, 510000.00000),
(25, 550000.00000),
(26, 590000.00000),
(27, 630000.00000),
(28, 670000.00000),
(29, 710000.00000),
(30, 760000.00000),
(31, 810000.00000),
(32, 860000.00000),
(33, 910000.00000),
(34, 960000.00000),
(35, 1010000.00000),
(36, 1060000.00000),
(37, 1110000.00000),
(38, 1165000.00000),
(39, 1220000.00000),
(40, 1280000.00000),
(41, 1340000.00000),
(42, 1400000.00000),
(43, 1460000.00000),
(44, 1520000.00000),
(45, 1600000.00000),
(46, 1830000.00000),
(47, 2060000.00000),
(48, 2290000.00000),
(49, 2520000.00000),
(50, 2750000.00000),
(51, 2980000.00000),
(52, 3210000.00000),
(53, 3440000.00000),
(54, 3670000.00000),
(55, 3900000.00000),
(56, 4130000.00000),
(57, 4360000.00000),
(58, 4590000.00000),
(59, 4820000.00000),
(60, 5050000.00000),
(61, 5280000.00000),
(62, 5510000.00000),
(63, 5740000.00000),
(64, 5970000.00000),
(65, 6200000.00000),
(66, 6430000.00000),
(67, 6660000.00000),
(68, 6890000.00000),
(69, 7120000.00000),
(70, 7350000.00000),
(71, 7580000.00000),
(72, 7810000.00000),
(73, 8040000.00000),
(74, 8270000.00000),
(75, 8500000.00000),
(76, 8730000.00000),
(77, 8960000.00000),
(78, 9190000.00000),
(79, 9420000.00000),
(80, 9650000.00000),
(81, 9880000.00000),
(82, 10110000.00000),
(83, 10340000.00000),
(84, 10570000.00000),
(85, 10800000.00000),
(86, 11030000.00000),
(87, 11260000.00000),
(88, 11490000.00000),
(89, 11720000.00000),
(90, 11950000.00000),
(91, 12180000.00000),
(92, 12410000.00000),
(93, 12640000.00000),
(94, 12870000.00000),
(95, 13100000.00000),
(96, 13330000.00000),
(97, 13560000.00000),
(98, 13790000.00000),
(99, 14020000.00000),
(100, 14250000.00000),
(101, 14480000.00000),
(102, 14710000.00000),
(103, 14940000.00000),
(104, 15170000.00000),
(105, 15400000.00000),
(106, 15630000.00000),
(107, 15860000.00000),
(108, 16090000.00000),
(109, 16320000.00000),
(110, 16550000.00000),
(111, 16780000.00000),
(112, 17010000.00000),
(113, 17240000.00000),
(114, 17470000.00000),
(115, 17700000.00000),
(116, 17930000.00000),
(117, 18160000.00000),
(118, 18390000.00000),
(119, 18620000.00000),
(120, 18850000.00000),
(121, 19080000.00000),
(122, 19310000.00000),
(123, 19540000.00000),
(124, 19770000.00000),
(125, 20000000.00000),
(126, 20230000.00000),
(127, 20460000.00000),
(128, 20690000.00000),
(129, 20920000.00000),
(130, 21150000.00000),
(131, 21380000.00000),
(132, 21610000.00000),
(133, 21840000.00000),
(134, 22070000.00000),
(135, 22300000.00000),
(136, 22530000.00000),
(137, 22760000.00000),
(138, 22990000.00000),
(139, 23220000.00000),
(140, 23450000.00000),
(141, 23680000.00000),
(142, 23910000.00000),
(143, 24140000.00000),
(144, 24370000.00000);

-- --------------------------------------------------------

--
-- Tabellstruktur `scorematrix`
--

CREATE TABLE `scorematrix` (
  `statname` varchar(255) COLLATE utf8_roman_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_roman_ci;

--
-- Dumpning av Data i tabell `scorematrix`
--

INSERT INTO `scorematrix` (`statname`) VALUES
('sc_assault'),
('sc_award'),
('sc_engineer'),
('sc_recon'),
('sc_specialkit'),
('sc_support'),
('sc_unlock'),
('sc_vehicleaa'),
('sc_vehicleah'),
('sc_vehicleart'),
('sc_vehicleifv'),
('sc_vehiclejet'),
('sc_vehiclelbt'),
('sc_vehiclembt'),
('sc_vehiclesh');

-- --------------------------------------------------------

--
-- Tabellstruktur `shoutbox`
--

CREATE TABLE `shoutbox` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `message` text NOT NULL,
  `time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Index för dumpade tabeller
--

--
-- Index för tabell `a_bf_dogtagssettings`
--
ALTER TABLE `a_bf_dogtagssettings`
  ADD PRIMARY KEY (`pid`,`client_type`);

--
-- Index för tabell `a_bf_emblems`
--
ALTER TABLE `a_bf_emblems`
  ADD PRIMARY KEY (`pid`);

--
-- Index för tabell `a_bf_gameservers`
--
ALTER TABLE `a_bf_gameservers`
  ADD PRIMARY KEY (`gid`);

--
-- Index för tabell `a_emu_achievements`
--
ALTER TABLE `a_emu_achievements`
  ADD PRIMARY KEY (`user_id`,`achievement_id`);

--
-- Index för tabell `a_emu_banned`
--
ALTER TABLE `a_emu_banned`
  ADD PRIMARY KEY (`mac`);

--
-- Index för tabell `a_emu_friends`
--
ALTER TABLE `a_emu_friends`
  ADD PRIMARY KEY (`user_id`,`pid`,`dsnm`,`jid`,`email`);

--
-- Index för tabell `a_emu_loginpersona`
--
ALTER TABLE `a_emu_loginpersona`
  ADD PRIMARY KEY (`gid`);

--
-- Index för tabell `a_emu_playerinfo`
--
ALTER TABLE `a_emu_playerinfo`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `email` (`email`),
  ADD KEY `staff_username` (`username`);

--
-- Index för tabell `a_emu_recentplayers`
--
ALTER TABLE `a_emu_recentplayers`
  ADD PRIMARY KEY (`pid`,`dsnm`);

--
-- Index för tabell `a_emu_subnets`
--
ALTER TABLE `a_emu_subnets`
  ADD UNIQUE KEY `Dst_ip` (`Dst_ip`);

--
-- Index för tabell `a_mohw_playerstats`
--
ALTER TABLE `a_mohw_playerstats`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `a_mohw_playerstats2`
--
ALTER TABLE `a_mohw_playerstats2`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `a_mohw_usersettings`
--
ALTER TABLE `a_mohw_usersettings`
  ADD PRIMARY KEY (`pid`,`key`);

--
-- Index för tabell `bf3_playerstats`
--
ALTER TABLE `bf3_playerstats`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `bf3_playerstatsunlock`
--
ALTER TABLE `bf3_playerstatsunlock`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `bf3_playerstats_coop`
--
ALTER TABLE `bf3_playerstats_coop`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `bf4_accessories`
--
ALTER TABLE `bf4_accessories`
  ADD PRIMARY KEY (`pid`,`name`);

--
-- Index för tabell `bf4_battlepacks`
--
ALTER TABLE `bf4_battlepacks`
  ADD PRIMARY KEY (`bid`);

--
-- Index för tabell `bf4_boosts`
--
ALTER TABLE `bf4_boosts`
  ADD PRIMARY KEY (`pid`);

--
-- Index för tabell `bf4_playerstats`
--
ALTER TABLE `bf4_playerstats`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `bf4_usersettings`
--
ALTER TABLE `bf4_usersettings`
  ADD PRIMARY KEY (`pid`,`key`);

--
-- Index för tabell `bfh_battlepacks`
--
ALTER TABLE `bfh_battlepacks`
  ADD PRIMARY KEY (`mPackId`,`mPackKey`,`mUserId`);

--
-- Index för tabell `bfh_boosts`
--
ALTER TABLE `bfh_boosts`
  ADD PRIMARY KEY (`uid`,`ckey`);

--
-- Index för tabell `bfh_playerstats`
--
ALTER TABLE `bfh_playerstats`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `bfh_playerstats2`
--
ALTER TABLE `bfh_playerstats2`
  ADD PRIMARY KEY (`pid`,`statname`),
  ADD KEY `pid` (`pid`),
  ADD KEY `statname` (`statname`);

--
-- Index för tabell `bfh_talliedconsumables`
--
ALTER TABLE `bfh_talliedconsumables`
  ADD PRIMARY KEY (`pid`,`ckey`);

--
-- Index för tabell `bfh_unlocks`
--
ALTER TABLE `bfh_unlocks`
  ADD PRIMARY KEY (`pid`,`name`);

--
-- Index för tabell `bfh_usersettings`
--
ALTER TABLE `bfh_usersettings`
  ADD PRIMARY KEY (`pid`,`key`);

--
-- Index för tabell `rankdata`
--
ALTER TABLE `rankdata`
  ADD PRIMARY KEY (`rank`);

--
-- Index för tabell `rankmatrix`
--
ALTER TABLE `rankmatrix`
  ADD PRIMARY KEY (`rank`),
  ADD UNIQUE KEY `rank` (`rank`);

--
-- Index för tabell `shoutbox`
--
ALTER TABLE `shoutbox`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT för dumpade tabeller
--

--
-- AUTO_INCREMENT för tabell `a_emu_loginpersona`
--
ALTER TABLE `a_emu_loginpersona`
  MODIFY `gid` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10016;

--
-- AUTO_INCREMENT för tabell `a_emu_playerinfo`
--
ALTER TABLE `a_emu_playerinfo`
  MODIFY `user_id` int(10) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT för tabell `bf4_battlepacks`
--
ALTER TABLE `bf4_battlepacks`
  MODIFY `bid` bigint(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT för tabell `bfh_battlepacks`
--
ALTER TABLE `bfh_battlepacks`
  MODIFY `mPackId` bigint(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT för tabell `rankdata`
--
ALTER TABLE `rankdata`
  MODIFY `rank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=146;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
