# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals

import math

from calendar_app.tests import CalendarTestCase

from datetime import datetime
from dateutil.relativedelta import relativedelta


class TestMonthView(CalendarTestCase):

    def get_currentDayStart(self):
        month_view = self.main_view.get_month_view()
        return month_view.currentMonth.datetime

    def change_month(self, delta):
        month_view = self.main_view.get_month_view()
        sign = int(math.copysign(1, delta))

        for _ in range(abs(delta)):
            before = self.get_currentDayStart()
            self.main_view.swipe_view(sign, month_view)
            after = before + relativedelta(months=sign)

            self.assertThat(lambda: self.get_currentDayStart().month,
                            Eventually(Equals(after.month)))
            self.assertThat(lambda: self.get_currentDayStart().year,
                            Eventually(Equals(after.year)))

    def _assert_today(self):
        today = datetime.today()
        self.assertThat(lambda: self.get_currentDayStart().day,
                        Eventually(Equals(today.day)))
        self.assertThat(lambda: self.get_currentDayStart().month,
                        Eventually(Equals(today.month)))
        self.assertThat(lambda: self.get_currentDayStart().year,
                        Eventually(Equals(today.year)))

    def _test_go_to_today(self, delta):
        self._assert_today()
        self.change_month(delta)
        self.main_view.open_toolbar().click_button("todaybutton")
        self._assert_today()

    def test_monthview_go_to_today_next_month(self):
        self._test_go_to_today(1)

    def test_monthview_go_to_today_prev_month(self):
        self._test_go_to_today(-1)

    def test_monthview_go_to_today_next_year(self):
        self._test_go_to_today(12)

    def test_monthview_go_to_today_prev_year(self):
        self._test_go_to_today(-12)
