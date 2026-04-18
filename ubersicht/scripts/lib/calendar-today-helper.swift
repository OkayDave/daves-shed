#!/usr/bin/env swift
import Foundation
import EventKit

struct RawEvent: Codable {
    let calendar: String
    let title: String
    let startTimestamp: String
    let endTimestamp: String
    let allDay: Bool
}

enum HelperError: Error {
    case accessDenied
    case accessFailed
}

func requestAccess(store: EKEventStore) throws {
    let semaphore = DispatchSemaphore(value: 0)
    var granted = false

    if #available(macOS 14.0, *) {
        store.requestFullAccessToEvents { ok, _ in
            granted = ok
            semaphore.signal()
        }
    } else {
        store.requestAccess(to: .event) { ok, _ in
            granted = ok
            semaphore.signal()
        }
    }

    semaphore.wait()

    if !granted {
        throw HelperError.accessDenied
    }
}

do {
    let store = EKEventStore()
    try requestAccess(store: store)

    let now = Date()
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: now)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

    let predicate = store.predicateForEvents(
        withStart: startOfDay,
        end: endOfDay,
        calendars: nil
    )

    let events = store.events(matching: predicate)

    let payload = events.map { event in
        RawEvent(
            calendar: event.calendar.title,
            title: event.title ?? "(Untitled)",
            startTimestamp: ISO8601DateFormatter().string(from: event.startDate),
            endTimestamp: ISO8601DateFormatter().string(from: event.endDate),
            allDay: event.isAllDay
        )
    }

    let encoder = JSONEncoder()
    let data = try encoder.encode(payload)
    print(String(data: data, encoding: .utf8)!)
} catch HelperError.accessDenied {
    print(#"{"error":"Calendar access denied"}"#)
    exit(0)
} catch {
    let message = error.localizedDescription.replacingOccurrences(of: "\"", with: "\\\"")
    print(#"{"error":"Could not fetch calendar events","detail":"\#(message)"}"#)
    exit(0)
}