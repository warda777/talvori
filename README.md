# Talvori

![Flutter](https://img.shields.io/badge/Flutter-Mobile-blue)
![Dart](https://img.shields.io/badge/Dart-Language-blue)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

Talvori is a mobile language learning application that implements a **transparent spaced-repetition system** designed to improve long-term vocabulary retention.

The project was developed as part of a **Bachelor thesis in Software Engineering** and focuses on making the internal learning logic of spaced repetition systems **visible and understandable to the user**.

---

# App Screenshots

### Word Hub

<p align="center">
<img src="docs/screenshots/wordhub.png" width="300">
</p>

The Word Hub organizes vocabulary into thematic categories and provides an overview of the learning content.

---

### Dashboard

<p align="center">
<img src="docs/screenshots/dashboard.png" width="300">
</p>

The dashboard shows:

- current learning mode  
- vocabulary progress  
- spaced repetition stages  
- daily learning progress  

---

### Learning Mode

<p align="center">
<img src="docs/screenshots/learning.png" width="300">
</p>

Interactive learning interface including:

- vocabulary cards  
- audio playback  
- learning progress indicators  

---

### Category Overview

<p align="center">
<img src="docs/screenshots/category.png" width="300">
</p>

Users can navigate categories and track vocabulary distribution across learning stages.

---

# Project Vision

Traditional spaced-repetition applications hide their internal learning logic behind algorithms.

Talvori takes a different approach.

The goal is to make the learning system **transparent and controllable** so that users understand:

- why a word appears
- when it will appear again
- how their learning progress evolves

This transparency supports **self-regulated learning** and allows learners to actively interact with the repetition system.

---

# Learning System

Talvori implements **three spaced-repetition modes**.

### Time-based Spaced Repetition (T-SRS)

A structured interval system where vocabulary appears again after predefined time intervals.

Example concept:
S0 → S1 → S2 → S3 → S4 → S5


Each stage represents increasing long-term retention.

---

### Adaptive Spaced Repetition (A-SRS)

An adaptive learning system that reacts to the learner's performance.

The system evaluates:

- correct answers
- streaks
- repetitions
- learning progress

Based on these signals the algorithm dynamically adjusts the learning stage.

---

### Hybrid Mode

Hybrid mode combines both approaches.

It merges:

- **time-based intervals**
- **adaptive difficulty**

This creates a balanced system that adapts to the learner while still maintaining structured repetition intervals.

---

# Key Features

Talvori focuses on making the learning system understandable and interactive.

Main features include:

- transparent spaced repetition system  
- three learning modes (T-SRS, A-SRS, Hybrid)  
- vocabulary stage visualization  
- category based vocabulary organization  
- modern mobile UI  
- real-time learning progress tracking  
- manual control of learning stages  

---

# Technologies

Frontend

- Flutter
- Dart

Backend

- Supabase
- PostgreSQL

Architecture

- MVC-inspired architecture
- REST-based backend communication

Development Tools

- Git
- GitHub

---

# Project Structure

Example simplified structure

lib
├── models
├── services
├── controllers
├── screens
└── widgets

backend
├── database
├── functions
└── migrations


---

# Research Context

This project was created as part of a **Bachelor thesis in Software Engineering**.

The research investigates how transparency in algorithm-driven learning systems influences:

- user understanding
- perceived control
- self-regulated learning behavior

Talvori therefore serves both as:

- a functional language learning application
- a research artifact for evaluating transparent learning algorithms

---

# Future Development

Planned improvements include:

- App Store release
- extended vocabulary datasets
- additional learning statistics
- improved adaptive learning algorithms
- cloud synchronization

---

# Author

Andreas Warda  
B.Sc. Software Engineering  
IU International University

GitHub  
https://github.com/warda777

---

# License

MIT License
