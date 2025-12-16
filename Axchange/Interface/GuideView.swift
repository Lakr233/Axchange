//
//  GuideView.swift
//  Axchange
//
//  Created by 秋星桥 on 2024/12/3.
//

import MarkdownUI
import SwiftUI

private let documentLink = URL(string: "https://developer.android.com/studio/debug/dev-options#enable")!
private let feedbackLink = URL(string: "https://github.com/Lakr233/Axchange/issues")!

struct GuideView: View {
    @State var openFeedbackAlert = false

    var body: some View {
        ScrollView(.vertical) {
            Markdown {
                Paragraph {
                    NSLocalizedString("Follow the instructions below to connect your device.", comment: "")
                }
                ThematicBreak()
                NumberedList {
                    ListItem {
                        NSLocalizedString("Enable ADB on Device", comment: "")
                        Paragraph {
                            NSLocalizedString("Please refer to", comment: "")
                            " "
                            InlineLink(NSLocalizedString("Google's Document", comment: ""), destination: documentLink)
                            " "
                            NSLocalizedString("to enable ADB on your device.", comment: "")
                        }
                        Paragraph {
                            NSLocalizedString("For different devices, the way to enable ADB may vary. Please refer to your device manual.", comment: "")
                        }
                    }
                    ListItem {
                        NSLocalizedString("Connect your device", comment: "")
                        Paragraph {
                            NSLocalizedString("Please connect your device via a cable.", comment: "")
                        }
                        Paragraph {
                            NSLocalizedString("For advanced users, setup a wireless connection on your own.", comment: "")
                        }
                    }
                    ListItem {
                        NSLocalizedString("Click Scan", comment: "")
                        Paragraph {
                            NSLocalizedString("For a stable user experience, please click the scan button to search for devices.", comment: "")
                        }
                        Paragraph {
                            NSLocalizedString("Please also authorize the connection on your device.", comment: "")
                        }
                    }
                }
            }
            .markdownTheme(Theme()
                .thematicBreak {
                    Divider()
                        .relativeFrame(height: .em(0.25))
                        .markdownMargin(top: 16, bottom: 16)
                })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            Button("Feedback") {
                NSWorkspace.shared.open(feedbackLink)
            }
        }
        .navigationTitle("Connect to Axchange")
    }
}
