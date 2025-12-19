import 'package:flutter/material.dart';

class CommentsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> comments;
  final VoidCallback onAddComment;

  const CommentsWidget({
    required this.comments,
    required this.onAddComment,
    super.key,
  });

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Questions & Answers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E4B),
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.add, size: 18),
                label: Text('Ask'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B5E4B),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: widget.onAddComment,
              ),
            ],
          ),
        ),

        // Comments List
        if (widget.comments.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No questions yet. Ask the first question!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
        else
          ...widget.comments.map((comment) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Questioner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (comment['userName'] ?? 'U')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['userName'] ?? 'Anonymous',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1B5E4B),
                                  ),
                                ),
                                Text(
                                  comment['daysAgo'] ?? 'Recently',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Chip(
                          label: Text('Q'),
                          backgroundColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      comment['text'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    // Like/Reply buttons
                    Row(
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.thumb_up_outlined, size: 16),
                          label: Text('Helpful'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Thanks for your feedback!'),
                                backgroundColor: Colors.green,
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        TextButton.icon(
                          icon: Icon(Icons.reply_outlined, size: 16),
                          label: Text('Reply'),
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF1B5E4B),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reply feature coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
