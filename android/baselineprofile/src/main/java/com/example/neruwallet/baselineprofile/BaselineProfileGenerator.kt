package com.example.neruwallet.baselineprofile

import androidx.benchmark.macro.junit4.BaselineProfileRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * This test class generates a Baseline Profile for the app.
 * Run this test to generate the profile in the `app/src/main/generated/baselineProfiles` directory.
 */
@RunWith(AndroidJUnit4::class)
class BaselineProfileGenerator {

    @get:Rule
    val baselineProfileRule = BaselineProfileRule()

    @Test
    fun generate() = baselineProfileRule.collect(
        packageName = "com.example.neruwallet",
        // Check if the app is ready to be benchmarked
        includeInvolvedProcesses = true
    ) {
        // This block defines the actions to take to generate the profile.
        // For a Flutter app, simply starting the app is often enough to 
        // capture the most important startup code paths.
        pressHome()
        startActivityAndWait()

        // You can add more interactions here to capture more code paths,
        // such as navigating to common screens.
        // Example:
        // device.wait(Until.hasObject(By.text("Login")), 5000)
    }
}
